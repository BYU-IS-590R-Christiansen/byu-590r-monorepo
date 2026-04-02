import 'package:flutter/material.dart';
import 'package:byu_590r_flutter_app/core/api_config.dart';

/// Shown on first launch of a release build when no API host IP is stored.
class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key, required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'Enter an IP address or hostname.');
      return;
    }
    // Allow hostname or IPv4; keep validation light.
    if (raw.contains(' ') || raw.contains('/')) {
      setState(() => _error = 'Enter only the host (no path or spaces).');
      return;
    }
    setState(() => _error = null);
    await ApiConfig.saveProductionIp(raw);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API server')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Release build: enter the machine running your Laravel API '
              '(port ${ApiConfig.apiPort}). Example: 192.168.1.10',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Host IP or hostname',
                hintText: '192.168.1.10',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
