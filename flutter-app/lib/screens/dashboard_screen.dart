import 'package:flutter/material.dart';

/// Signed-in home tab: greeting and shortcuts to other sections.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.displayName,
    required this.onOpenProfile,
    required this.onOpenBooks,
  });

  final String displayName;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenBooks;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final first = displayName.trim().split(RegExp(r'\s+')).first;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  first.isEmpty ? displayName : first,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _NavCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  subtitle: 'View your account details',
                  color: cs.primaryContainer,
                  onTap: onOpenProfile,
                ),
                const SizedBox(height: 12),
                _NavCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Books',
                  subtitle: 'Browse the library catalog',
                  color: cs.secondaryContainer,
                  onTap: onOpenBooks,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade800,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade700),
            ],
          ),
        ),
      ),
    );
  }
}
