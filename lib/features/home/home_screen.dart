import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _WelcomeBanner(),
                      const SizedBox(height: 28),
                      _SectionLabel('YOUR PILLARS'),
                      const SizedBox(height: 14),
                      _PillarIconsRow(),
                      const SizedBox(height: 28),
                      _SectionLabel('SERVICES'),
                      const SizedBox(height: 14),
                      _ServicesGrid(),
                      const SizedBox(height: 28),
                      _SectionLabel('TOOLS'),
                      const SizedBox(height: 14),
                      _ToolsGrid(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Image.asset(
            'assets/branding/otic_logo.png',
            width: 36, height: 36, fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          const Text(
            'Otic Connect',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
            ),
          ),
          const Spacer(),
          _CircleButton(Icons.notifications_outlined, () {}),
          const SizedBox(width: 8),
          _CircleButton(Icons.person_outlined, () => context.go('/profile')),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton(this.icon, this.onTap);
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.25),
            AppColors.growColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.online.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_done, size: 12, color: AppColors.online),
                      SizedBox(width: 4),
                      Text('Online', style: TextStyle(fontSize: 11, color: AppColors.online, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Connect to\nopportunity',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Learn, Earn, Grow & Thrive',
                  style: TextStyle(fontSize: 13, color: Color(0xAAFFFFFF)),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/branding/otic_logo.png',
            width: 64, height: 64, fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2,
        color: Color(0x88FFFFFF),
      ),
    );
  }
}

class _PillarIconsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pillars = [
      _IconItem('Learn', Icons.menu_book_rounded, AppColors.learnColor, '/learn'),
      _IconItem('Earn', Icons.account_balance_wallet_rounded, AppColors.earnColor, '/marketplace'),
      _IconItem('Grow', Icons.trending_up_rounded, AppColors.growColor, '/mentorship'),
      _IconItem('Thrive', Icons.favorite_rounded, AppColors.thriveColor, '/health'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: pillars.map((p) => _RoundedIconTile(item: p)).toList(),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _IconItem('Market', Icons.storefront_rounded, AppColors.marketplaceColor, '/marketplace'),
      _IconItem('Finance', Icons.savings_rounded, AppColors.financeColor, '/financial'),
      _IconItem('Mentors', Icons.diversity_1_rounded, AppColors.mentorshipColor, '/mentorship'),
      _IconItem('Jobs', Icons.work_rounded, AppColors.jobsColor, '/jobs'),
      _IconItem('Skills', Icons.auto_awesome_rounded, AppColors.skillsColor, '/skills'),
      _IconItem('Health', Icons.favorite_rounded, AppColors.healthColor, '/health'),
      _IconItem('Community', Icons.people_rounded, AppColors.communityColor, '/community'),
      _IconItem('Wellbeing', Icons.spa_rounded, AppColors.wellbeingColor, '/wellbeing'),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 12,
      childAspectRatio: 0.75,
      children: items.map((i) => _RoundedIconTile(item: i)).toList(),
    );
  }
}

class _ToolsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _IconItem('AI Chat', Icons.chat_rounded, AppColors.chatColor, '/ai-chat'),
      _IconItem('Profile', Icons.person_rounded, AppColors.profileColor, '/profile'),
      _IconItem('Settings', Icons.settings_rounded, AppColors.settingsColor, '/settings'),
    ];

    return Row(
      children: items.map((i) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _RoundedIconTile(item: i),
      )).toList(),
    );
  }
}

class _RoundedIconTile extends StatelessWidget {
  const _RoundedIconTile({required this.item});
  final _IconItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.path),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(item.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: Color(0xCCFFFFFF),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconItem {
  const _IconItem(this.label, this.icon, this.color, this.path);
  final String label;
  final IconData icon;
  final Color color;
  final String path;
}
