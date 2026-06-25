import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static final mobileScaffoldKey = GlobalKey<ScaffoldState>();

  static const _destinations = [
    _NavDest('Home', Icons.home_rounded, Icons.home_rounded, '/'),
    _NavDest('Learn', Icons.menu_book_rounded, Icons.menu_book_rounded, '/learn'),
    _NavDest('Market', Icons.storefront_rounded, Icons.storefront_rounded, '/marketplace'),
    _NavDest('Community', Icons.people_rounded, Icons.people_rounded, '/community'),
    _NavDest('Chat', Icons.chat_rounded, Icons.chat_rounded, '/ai-chat'),
  ];

  static const _allDestinations = [
    _NavDest('Home', Icons.home_outlined, Icons.home, '/'),
    _NavDest('Learn', Icons.menu_book_outlined, Icons.menu_book, '/learn'),
    _NavDest('Market', Icons.storefront_outlined, Icons.storefront, '/marketplace'),
    _NavDest('Finance', Icons.savings_outlined, Icons.savings, '/financial'),
    _NavDest('Mentors', Icons.diversity_1_outlined, Icons.diversity_1, '/mentorship'),
    _NavDest('Jobs', Icons.work_outline, Icons.work, '/jobs'),
    _NavDest('Skills', Icons.auto_awesome_outlined, Icons.auto_awesome, '/skills'),
    _NavDest('Health', Icons.favorite_outline, Icons.favorite, '/health'),
    _NavDest('Community', Icons.people_outlined, Icons.people, '/community'),
    _NavDest('Wellbeing', Icons.spa_outlined, Icons.spa, '/wellbeing'),
    _NavDest('AI Chat', Icons.chat_outlined, Icons.chat, '/ai-chat'),
    _NavDest('Profile', Icons.person_outlined, Icons.person, '/profile'),
    _NavDest('Settings', Icons.settings_outlined, Icons.settings, '/settings'),
  ];

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final i = _allDestinations.indexWhere((d) => d.path == path);
    return i < 0 ? 0 : i;
  }

  int _mobileIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final i = _destinations.indexWhere((d) => d.path == path);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);
    final isWide = MediaQuery.sizeOf(context).width >= 640;

    if (isWide) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              _SideNav(selectedIndex: selectedIndex, destinations: _allDestinations),
              Container(width: 1, color: const Color(0x22FFFFFF)),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    final mobileSelected = _mobileIndex(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgTop, AppColors.bgBottom],
        ),
      ),
      child: Scaffold(
        key: mobileScaffoldKey,
        backgroundColor: Colors.transparent,
        body: child,
        drawer: _AppDrawer(
          selectedIndex: selectedIndex,
          destinations: _allDestinations,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF083E3E),
            border: Border(top: BorderSide(color: Color(0x22FFFFFF))),
          ),
          child: NavigationBar(
            selectedIndex: mobileSelected,
            onDestinationSelected: (i) => context.go(_destinations[i].path),
            backgroundColor: Colors.transparent,
            destinations: _destinations.map((d) => NavigationDestination(
              icon: Icon(d.icon, color: const Color(0x88FFFFFF)),
              selectedIcon: Icon(d.selectedIcon, color: AppColors.accent),
              label: d.label,
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.selectedIndex, required this.destinations});
  final int selectedIndex;
  final List<_NavDest> destinations;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF072F2F),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset('assets/branding/otic_logo.png', width: 36, height: 36, fit: BoxFit.contain),
                const SizedBox(width: 10),
                const Text('Otic She Connect', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0x22FFFFFF)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: destinations.length,
              itemBuilder: (context, i) {
                final dest = destinations[i];
                final selected = selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    dense: true,
                    selected: selected,
                    selectedTileColor: AppColors.accent.withValues(alpha: 0.15),
                    leading: Icon(
                      selected ? dest.selectedIcon : dest.icon,
                      color: selected ? AppColors.accent : const Color(0x99FFFFFF),
                      size: 20,
                    ),
                    title: Text(
                      dest.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? AppColors.accent : const Color(0x99FFFFFF),
                      ),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onTap: () => context.go(dest.path),
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: const Color(0x22FFFFFF)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text('Online · v1.0', style: TextStyle(fontSize: 12, color: Color(0x66FFFFFF))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.selectedIndex, required this.destinations});
  final int selectedIndex;
  final List<_NavDest> destinations;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF072F2F),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Image.asset('assets/branding/otic_logo.png', width: 40, height: 40, fit: BoxFit.contain),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Otic She Connect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('Connecting Women to Opportunity', style: TextStyle(fontSize: 11, color: Color(0x88FFFFFF))),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: const Color(0x22FFFFFF)),
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, i) {
                  final dest = destinations[i];
                  final selected = selectedIndex == i;
                  return ListTile(
                    dense: true,
                    selected: selected,
                    selectedTileColor: AppColors.accent.withValues(alpha: 0.15),
                    leading: Icon(
                      selected ? dest.selectedIcon : dest.icon,
                      color: selected ? AppColors.accent : const Color(0x99FFFFFF),
                      size: 20,
                    ),
                    title: Text(
                      dest.label,
                      style: TextStyle(
                        fontSize: 14, color: selected ? AppColors.accent : const Color(0xCCFFFFFF),
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      context.go(dest.path);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavDest {
  const _NavDest(this.label, this.icon, this.selectedIcon, this.path);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}
