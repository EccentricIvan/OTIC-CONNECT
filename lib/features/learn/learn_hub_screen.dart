import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/feature_card.dart';

class LearnHubScreen extends StatelessWidget {
  const LearnHubScreen({super.key});

  static const _categories = [
    _Category('Digital Skills', 'Computers, internet, and mobile basics',
        Icons.computer, AppColors.skillsColor, 8),
    _Category('Financial Literacy', 'Budgeting, savings, and money management',
        Icons.account_balance, AppColors.financeColor, 6),
    _Category('Entrepreneurship', 'Start and grow your business',
        Icons.rocket_launch, AppColors.earnColor, 10),
    _Category('Agriculture', 'Modern farming techniques and agribusiness',
        Icons.agriculture, AppColors.healthColor, 7),
    _Category('Health & Nutrition', 'Family health, nutrition, and wellness',
        Icons.favorite, AppColors.thriveColor, 5),
    _Category('Leadership', 'Community leadership and advocacy skills',
        Icons.emoji_events, AppColors.growColor, 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LearnHero(),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Browse Topics',
                  subtitle: 'Practical skills for everyday life',
                ),
                const SizedBox(height: 12),
                ..._categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FeatureCard(
                      title: c.title,
                      subtitle: c.subtitle,
                      icon: c.icon,
                      color: c.color,
                      onTap: () {},
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${c.lessonCount} lessons',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'AI Learning Assistant',
                  subtitle: 'Ask any question and get instant help',
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  title: 'Ask AI Assistant',
                  subtitle:
                      'Get personalised answers on business, farming, health, and more',
                  icon: Icons.chat,
                  color: AppColors.primary,
                  onTap: () => context.go('/ai-chat'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LearnHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.learnColor.withValues(alpha: 0.12),
            AppColors.learnColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.learnColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Knowledge is power',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Access practical courses designed for women — from digital skills to business management, all in your language.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.learnColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.menu_book,
                color: AppColors.learnColor, size: 28),
          ),
        ],
      ),
    );
  }
}

class _Category {
  const _Category(
      this.title, this.subtitle, this.icon, this.color, this.lessonCount);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int lessonCount;
}
