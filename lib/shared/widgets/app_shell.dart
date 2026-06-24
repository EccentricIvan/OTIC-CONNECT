import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static final mobileScaffoldKey = GlobalKey<ScaffoldState>();

  static const _destinations = [
    _NavDest('Home', Icons.home_outlined, Icons.home, '/'),
    _NavDest('Learn', Icons.menu_book_outlined, Icons.menu_book, '/learn'),
    _NavDest('Market', Icons.storefront_outlined, Icons.storefront, '/marketplace'),
    _NavDest('Community', Icons.people_outlined, Icons.people, '/community'),
    _NavDest('Finance', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, '/financial'),
    _NavDest('Mentorship', Icons.diversity_1_outlined, Icons.diversity_1, '/mentorship'),
    _NavDest('Jobs', Icons.work_outline, Icons.work, '/jobs'),
    _NavDest('Skills', Icons.auto_awesome_outlined, Icons.auto_awesome, '/skills'),
    _NavDest('Health', Icons.favorite_outline, Icons.favorite, '/health'),
    _NavDest('Wellbeing', Icons.spa_outlined, Icons.spa, '/wellbeing'),
    _NavDest('AI Assistant', Icons.chat_outlined, Icons.chat, '/ai-chat'),
    _NavDest('Profile', Icons.person_outlined, Icons.person, '/profile'),
    _NavDest('Settings', Icons.settings_outlined, Icons.settings, '/settings'),
  ];

  static const _mobileIndices = [0, 1, 2, 3, 4];

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final i = _destinations.indexWhere((d) => d.path == path);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);
    final isWide = MediaQuery.sizeOf(context).width >= 640;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _SideNav(
                selectedIndex: selectedIndex, destinations: _destinations),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    final mobileSelected = _mobileIndices.contains(selectedIndex)
        ? _mobileIndices.indexOf(selectedIndex)
        : 0;

    return Scaffold(
      key: mobileScaffoldKey,
      body: Stack(
        children: [
          child,
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            right: 4,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.menu, size: 22),
                  tooltip: 'Menu',
                  onPressed: () =>
                      mobileScaffoldKey.currentState?.openDrawer(),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.85),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _AppDrawer(
        selectedIndex: selectedIndex,
        destinations: _destinations,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: NavigationBar(
          selectedIndex: mobileSelected,
          onDestinationSelected: (i) =>
              context.go(_destinations[_mobileIndices[i]].path),
          destinations: _mobileIndices
              .map(
                (i) => NavigationDestination(
                  icon: Icon(_destinations[i].icon),
                  selectedIcon: Icon(_destinations[i].selectedIcon),
                  label: _destinations[i].label,
                ),
              )
              .toList(),
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
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF5EEAD4)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hub, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'Otic Connect',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: destinations.length,
              itemBuilder: (context, i) {
                final dest = destinations[i];
                final selected = selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    dense: true,
                    selected: selected,
                    selectedTileColor:
                        AppColors.primary.withValues(alpha: 0.08),
                    leading: Icon(
                      selected ? dest.selectedIcon : dest.icon,
                      color: selected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    title: Text(
                      dest.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () => context.go(dest.path),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Online · v1.0',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer(
      {required this.selectedIndex, required this.destinations});

  final int selectedIndex;
  final List<_NavDest> destinations;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) {
        context.go(destinations[i].path);
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF5EEAD4)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.hub, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Otic Connect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            'Connecting Women to Opportunity',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        const Divider(indent: 16, endIndent: 16),
        ...destinations.map(
          (d) => NavigationDrawerDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          ),
        ),
      ],
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
