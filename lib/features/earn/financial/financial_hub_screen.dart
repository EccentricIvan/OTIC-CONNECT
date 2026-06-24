import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/feature_card.dart';

class FinancialHubScreen extends StatelessWidget {
  const FinancialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Hub')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FinanceHero(),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Financial Tools',
                  subtitle: 'Manage your money wisely',
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  title: 'Savings Tracker',
                  subtitle: 'Set goals and track your savings progress',
                  icon: Icons.savings,
                  color: AppColors.financeColor,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                FeatureCard(
                  title: 'Budget Planner',
                  subtitle: 'Plan your income and expenses',
                  icon: Icons.pie_chart,
                  color: AppColors.earnColor,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                FeatureCard(
                  title: 'SACCO Directory',
                  subtitle: 'Find savings groups and cooperatives near you',
                  icon: Icons.groups,
                  color: AppColors.communityColor,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                FeatureCard(
                  title: 'Mobile Money Guide',
                  subtitle: 'Learn to send, receive, and save with mobile money',
                  icon: Icons.phone_android,
                  color: AppColors.primary,
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Financial Literacy',
                  subtitle: 'Build your money knowledge',
                ),
                const SizedBox(height: 12),
                _FinancialTips(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FinanceHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.financeColor.withValues(alpha: 0.12),
            AppColors.earnColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.financeColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take control of your finances',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tools and resources to help you save, budget, and grow your money.',
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
              color: AppColors.financeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance_wallet,
                color: AppColors.financeColor, size: 28),
          ),
        ],
      ),
    );
  }
}

class _FinancialTips extends StatelessWidget {
  static const _tips = [
    ('Start Small', 'Even saving 500 UGX a day adds up over time'),
    ('Track Expenses', 'Know where your money goes each week'),
    ('Join a SACCO', 'Group savings help you access loans and support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _tips.map((t) {
        return Card(
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.earnColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb,
                  color: AppColors.earnColor, size: 18),
            ),
            title: Text(t.$1,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(t.$2),
          ),
        );
      }).toList(),
    );
  }
}
