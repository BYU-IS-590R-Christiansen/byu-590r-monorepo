import 'package:flutter/material.dart';
import 'package:byu_590r_flutter_app/core/api_client.dart';
import 'package:byu_590r_flutter_app/screens/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.accessToken});

  final String accessToken;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> _loadProfile() async {
    final dynamic res = await _apiClient.getUserProfileData(widget.accessToken);
    if (res is Map<String, dynamic>) return res;
    return null;
  }

  Future<void> _logout() async {
    await _apiClient.logout(widget.accessToken);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null || data['results'] == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snapshot.error?.toString() ?? 'Could not load profile.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final r = data['results'] as Map<String, dynamic>;
        final name = r['name'] as String? ?? '';
        final email = r['email'] as String? ?? '';
        final avatar = (r['avatar'] as String?) ?? '';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: _Avatar(url: avatar, colorScheme: cs),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Full name'),
                    subtitle: Text(name),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(email),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(
                  color: cs.error.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.colorScheme});

  final String url;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.person_rounded,
          size: 48,
          color: colorScheme.primary,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: 48,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.person_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
