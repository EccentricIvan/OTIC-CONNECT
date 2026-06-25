import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/pillar_card.dart';
import '../../shared/widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/branding/otic_logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text('Otic Connect'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroSection(),
                const SizedBox(height: 28),
                const SectionHeader(
                  title: 'Your Pillars',
                  subtitle: 'Learn, Earn, Grow, and Thrive',
                ),
                const SizedBox(height: 12),
                _PillarsGrid(),
                const SizedBox(height: 28),
                const SectionHeader(
                  title: 'Quick Access',
                  subtitle: 'Popular features and services',
                ),
                const SizedBox(height: 12),
                _QuickAccessSection(),
                const SizedBox(height: 28),
                const _CommunityHighlight(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.thriveColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done_outlined,
                    size: 13, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Online & Offline · Always Connected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connect to\nopportunity',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Your AI-powered companion for economic resilience, digital inclusion, and community wellbeing.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/ai-chat'),
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Ask AI Assistant'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/learn'),
                icon: const Icon(Icons.menu_book, size: 18),
                label: const Text('Learn'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillarsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pillars = [
      _Pillar(
        'Learn',
        'Access courses, digital skills, and financial literacy resources',
        Icons.menu_book,
        AppColors.learnColor,
        '/learn',
      ),
      _Pillar(
        'Earn',
        'Connect to markets, sell products, and manage your finances',
        Icons.account_balance_wallet,
        AppColors.earnColor,
        '/marketplace',
      ),
      _Pillar(
        'Grow',
        'Find mentors, job opportunities, and build new skills',
        Icons.trending_up,
        AppColors.growColor,
        '/mentorship',
      ),
      _Pillar(
        'Thrive',
        'Health resources, wellbeing support, and community networks',
        Icons.favorite,
        AppColors.thriveColor,
        '/health',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 520 ? 4 : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: cols == 4 ? 0.75 : 0.82,
          children: pillars
              .map(
                (p) => PillarCard(
                  title: p.title,
                  description: p.description,
                  icon: p.icon,
                  color: p.color,
                  onTap: () => context.go(p.path),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Pillar {
  const _Pillar(
      this.title, this.description, this.icon, this.color, this.path);
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String path;
}

class _QuickAccessSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FeatureCard(
          title: 'Marketplace',
          subtitle: 'Buy and sell products in your community',
          icon: Icons.storefront,
          color: AppColors.marketplaceColor,
          onTap: () => context.go('/marketplace'),
        ),
        const SizedBox(height: 8),
        FeatureCard(
          title: 'Financial Hub',
          subtitle: 'Savings tools, SACCO info, and financial literacy',
          icon: Icons.savings,
          color: AppColors.financeColor,
          onTap: () => context.go('/financial'),
        ),
        const SizedBox(height: 8),
        FeatureCard(
          title: 'Find a Mentor',
          subtitle: 'Connect with experienced women in your field',
          icon: Icons.diversity_1,
          color: AppColors.mentorshipColor,
          onTap: () => context.go('/mentorship'),
        ),
        const SizedBox(height: 8),
        FeatureCard(
          title: 'Job Board',
          subtitle: 'Browse employment and opportunity listings',
          icon: Icons.work,
          color: AppColors.jobsColor,
          onTap: () => context.go('/jobs'),
        ),
      ],
    );
  }
}

class _CommunityHighlight extends StatelessWidget {
  const _CommunityHighlight();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.communityColor.withValues(alpha: 0.12),
            AppColors.thriveColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.communityColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Your Community',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Connect with women\'s groups, share experiences, and grow together.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/community'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.communityColor,
                  ),
                  child: const Text('Explore Groups'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.communityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.people,
                color: AppColors.communityColor, size: 32),
          ),
        ],
      ),
    );
  }
}
