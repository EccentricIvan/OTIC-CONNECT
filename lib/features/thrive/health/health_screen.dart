import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/feature_card.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health & Wellbeing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HealthHero(),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Health Resources',
                  subtitle: 'Trusted information for you and your family',
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  title: 'Maternal Health',
                  subtitle: 'Pregnancy, postnatal care, and family planning',
                  icon: Icons.pregnant_woman,
                  color: AppColors.thriveColor,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                FeatureCard(
                  title: 'Nutrition Guide',
                  subtitle: 'Healthy eating for you and your children',
                  icon: Icons.restaurant,
                  color: AppColors.healthColor,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                FeatureCard(
                  title: 'Child Health',
                  subtitle: 'Immunisation schedules, common illnesses, and care',
                  icon: Icons.child_care,
                  color: AppColors.financeColor,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                FeatureCard(
                  title: 'Mental Wellness',
                  subtitle: 'Stress management, self-care, and emotional support',
                  icon: Icons.spa,
                  color: AppColors.wellbeingColor,
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Nearby Services',
                  subtitle: 'Health facilities and services in your area',
                ),
                const SizedBox(height: 12),
                _NearbyServices(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.healthColor.withValues(alpha: 0.12),
            AppColors.thriveColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.healthColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your health matters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Access trusted health information and connect with services in your community.',
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
              color: AppColors.healthColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.favorite,
                color: AppColors.healthColor, size: 28),
          ),
        ],
      ),
    );
  }
}

class _NearbyServices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final services = [
      ('Nakasero Hospital', 'Health Centre IV · 2.3 km',
          Icons.local_hospital, AppColors.healthColor),
      ('Mulago Women\'s Clinic', 'Specialised · 4.1 km',
          Icons.medical_services, AppColors.thriveColor),
      ('Community Health Post', 'Health Centre II · 0.8 km',
          Icons.health_and_safety, AppColors.financeColor),
    ];

    return Column(
      children: services.map((s) {
        return Card(
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: s.$4.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(s.$3, color: s.$4, size: 22),
            ),
            title: Text(s.$1,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(s.$2),
            trailing: Icon(Icons.directions,
                color: AppColors.primary, size: 20),
          ),
        );
      }).toList(),
    );
  }
}
