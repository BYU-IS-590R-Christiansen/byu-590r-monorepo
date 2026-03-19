<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Client\Response as HttpResponse;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OpenAIController extends BaseController
{
    protected string $baseUrl = 'https://api.openai.com/v1';

    /**
     * Generate suggested book inputs for the Books create dialog.
     *
     * @return array{name: string, description: string}
     */
    public function generateBookFormData(?string $genreName = null): array
    {
        $apiKey = env('OPENAI_API_KEY');
        if (empty($apiKey)) {
            return $this->fallbackBookFormData($genreName);
        }

        $model = env('OPENAI_MODEL', 'gpt-4o-mini');
        // Used to encourage different generations on repeated runs.
        $nonce = bin2hex(random_bytes(8));
        $genreName = $genreName ? trim($genreName) : null;

        $genreClause = $genreName ? "The genre is '{$genreName}'. " : '';

        $messages = [
            [
                'role' => 'system',
                'content' =>
                    'You are a helpful assistant that returns ONLY valid JSON. ' .
                    'Every request has a unique id and you MUST produce a different title/description than you would for a different id.',
            ],
            [
                'role' => 'user',
                'content' => $genreClause .
                    "Request id: {$nonce}. " .
                    'Suggest a great book title (max 60 characters) and a short description (max 250 characters) ' .
                    'for a library inventory app. ' .
                    "Return a JSON object with keys: name, description. Do not include any other keys.",
            ],
        ];

        try {
            /** @var HttpResponse $response */
            $response = Http::withToken($apiKey)->timeout(20)->post($this->baseUrl . '/chat/completions', [
                'model' => $model,
                'messages' => $messages,
                'temperature' => 1.0,
                'top_p' => 0.95,
                'presence_penalty' => 0.9,
                'frequency_penalty' => 0.3,
                'max_tokens' => 300,
                'response_format' => ['type' => 'json_object'],
                'user' => $nonce,
            ]);

            if (! $response->successful()) {
                Log::warning('OpenAI book form generation failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
                return $this->fallbackBookFormData($genreName);
            }

            $payload = $response->json();
            $content = $payload['choices'][0]['message']['content'] ?? null;
            $parsed = $this->tryParseJsonObject($content);

            if (
                ! is_array($parsed) ||
                empty($parsed['name']) ||
                empty($parsed['description']) ||
                ! is_string($parsed['name']) ||
                ! is_string($parsed['description'])
            ) {
                return $this->fallbackBookFormData($genreName);
            }

            return [
                'name' => mb_substr(trim($parsed['name']), 0, 60),
                'description' => mb_substr(trim($parsed['description']), 0, 250),
            ];
        } catch (\Throwable $e) {
            Log::error('OpenAI book form generation exception: ' . $e->getMessage(), [
                'exception' => $e,
            ]);
            return $this->fallbackBookFormData($genreName);
        }
    }

    /**
     * @return array{name: string, description: string}
     */
    private function fallbackBookFormData(?string $genreName = null): array
    {
        $genre = $genreName ? trim($genreName) : 'General';
        return [
            'name' => $genre . ' Book',
            'description' => 'A compelling read tailored for your library collection in the ' . $genre . ' genre.',
        ];
    }

    /**
     * @return array<mixed>|null
     */
    private function tryParseJsonObject(?string $content): ?array
    {
        if (empty($content)) {
            return null;
        }

        $normalized = trim($content);
        // Handle cases where the model wraps JSON in markdown fences.
        $normalized = preg_replace('/^```(?:json)?\s*/i', '', $normalized);
        $normalized = preg_replace('/\s*```$/', '', $normalized);

        $decoded = json_decode($normalized, true);
        return is_array($decoded) ? $decoded : null;
    }
}

