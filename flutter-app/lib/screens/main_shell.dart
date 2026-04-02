import 'package:flutter/material.dart';
import 'package:byu_590r_flutter_app/core/api_client.dart';
import 'package:byu_590r_flutter_app/screens/books_screen.dart';
import 'package:byu_590r_flutter_app/screens/dashboard_screen.dart';
import 'package:byu_590r_flutter_app/screens/profile_screen.dart';

/// Signed-in area: home dashboard, profile, and books.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.accessToken});

  final String accessToken;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final ApiClient _api = ApiClient();
  int _index = 0;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final dynamic res = await _api.getUserProfileData(widget.accessToken);
    if (!mounted) return;
    if (res is Map<String, dynamic> && res['results'] != null) {
      final r = res['results'];
      if (r is Map<String, dynamic>) {
        setState(() => _displayName = r['name'] as String? ?? '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: [
          DashboardScreen(
            displayName: _displayName.isEmpty ? 'Member' : _displayName,
            onOpenProfile: () => setState(() => _index = 1),
            onOpenBooks: () => setState(() => _index = 2),
          ),
          ProfileScreen(accessToken: widget.accessToken),
          BooksScreen(
            accessToken: widget.accessToken,
            embedded: true,
          ),
        ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Books',
          ),
        ],
      ),
    );
  }
}
