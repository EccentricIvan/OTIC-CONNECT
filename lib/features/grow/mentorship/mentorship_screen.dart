import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';

class MentorshipScreen extends StatelessWidget {
  const MentorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentorship')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MentorshipHero(),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Find a Mentor',
                  subtitle: 'Connect with experienced women who can guide you',
                ),
                const SizedBox(height: 12),
                _MentorsList(),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Become a Mentor',
                  subtitle: 'Share your experience and uplift others',
                ),
                const SizedBox(height: 12),
                _BecomeMentorCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MentorshipHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mentorshipColor.withValues(alpha: 0.12),
            AppColors.growColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.mentorshipColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grow with guidance',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Every successful woman had someone who believed in her. Find your mentor or become one.',
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
              color: AppColors.mentorshipColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.diversity_1,
                color: AppColors.mentorshipColor, size: 28),
          ),
        ],
      ),
    );
  }
}

class _MentorsList extends StatelessWidget {
  static const _mentors = [
    _Mentor('Amina B.', 'Agriculture & Agribusiness', 'Kampala',
        '12 years experience'),
    _Mentor('Florence N.', 'Financial Management', 'Jinja',
        '8 years experience'),
    _Mentor('Esther K.', 'Digital Marketing', 'Mbale',
        '5 years experience'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _mentors.map((m) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  AppColors.mentorshipColor.withValues(alpha: 0.12),
              child: Text(
                m.name[0],
                style: const TextStyle(
                  color: AppColors.mentorshipColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(m.name,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.expertise),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 12, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(
                      '${m.location} · ${m.experience}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Connect', style: TextStyle(fontSize: 12)),
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }
}

class _Mentor {
  const _Mentor(this.name, this.expertise, this.location, this.experience);
  final String name;
  final String expertise;
  final String location;
  final String experience;
}

class _BecomeMentorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.growColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.growColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share your knowledge',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Help other women grow by sharing your skills and experience. '
            'Being a mentor is one of the most impactful things you can do.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.growColor,
            ),
            child: const Text('Apply to Mentor'),
          ),
        ],
      ),
    );
  }
}
