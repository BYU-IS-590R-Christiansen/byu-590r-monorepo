<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset your password</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f4f4f5;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #f4f4f5; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width: 480px; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.07); overflow: hidden;">
                    <tr>
                        <td style="padding: 40px 32px 24px; text-align: center; border-bottom: 1px solid #e5e7eb;">
                            <h1 style="margin: 0; font-size: 22px; font-weight: 600; color: #111827;">Reset your password</h1>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 32px;">
                            <p style="margin: 0 0 24px; font-size: 16px; line-height: 1.6; color: #4b5563;">
                                You requested a password reset. Click the button below to choose a new password.
                            </p>
                            <table role="presentation" cellspacing="0" cellpadding="0" style="margin: 0 auto;">
                                <tr>
                                    <td style="border-radius: 8px; background-color: #2563eb;">
                                        <a href="{{ $base_url }}/api/password_reset?remember_token={{ $user->remember_token }}" target="_blank" style="display: inline-block; padding: 14px 28px; font-size: 16px; font-weight: 600; color: #ffffff; text-decoration: none;">
                                            Reset password
                                        </a>
                                    </td>
                                </tr>
                            </table>
                            <p style="margin: 24px 0 0; font-size: 14px; line-height: 1.5; color: #6b7280;">
                                If you didn't request this, you can ignore this email.
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 24px 32px; font-size: 12px; color: #9ca3af; text-align: center; border-top: 1px solid #e5e7eb;">
                            This link will expire after use.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
