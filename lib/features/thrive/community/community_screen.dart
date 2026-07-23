import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageService = ref.watch(offlineLanguageServiceProvider);
    String t(String key) => languageService.t(key);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('community')),
        actions: [
          IconButton(icon: const Icon(Icons.group_add), onPressed: () {}),
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
                _CommunityHero(t: t),
                const SizedBox(height: 24),
                SectionHeader(
                  title: t('your_groups'),
                  subtitle: t('your_groups_desc'),
                ),
                const SizedBox(height: 12),
                _EmptyGroupsState(t: t),
                const SizedBox(height: 24),
                SectionHeader(
                  title: t('discover_groups'),
                  subtitle: t('discover_groups_desc'),
                ),
                const SizedBox(height: 12),
                _DiscoverGroups(t: t),
                const SizedBox(height: 24),
                SectionHeader(
                  title: t('community_feed'),
                  subtitle: t('community_feed_desc'),
                ),
                const SizedBox(height: 12),
                _CommunityFeed(t: t),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityHero extends StatelessWidget {
  const _CommunityHero({required this.t});
  final String Function(String) t;

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
          color: AppColors.communityColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('community_hero_title'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  t('community_hero_desc'),
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
              color: AppColors.communityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.people,
              color: AppColors.communityColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  const _EmptyGroupsState({required this.t});
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(Icons.groups, size: 48, color: Theme.of(context).hintColor),
          const SizedBox(height: 12),
          Text(
            t('no_groups_yet'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            t('join_or_create_group'),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: Text(t('create_group')),
          ),
        ],
      ),
    );
  }
}

class _DiscoverGroups extends StatelessWidget {
  const _DiscoverGroups({required this.t});
  final String Function(String) t;

  static const _groups = [
    _Group(
      'group_kampala_women_entrepreneurs',
      124,
      Icons.trending_up,
      AppColors.earnColor,
    ),
    _Group(
      'group_digital_skills_network',
      89,
      Icons.computer,
      AppColors.skillsColor,
    ),
    _Group(
      'group_farmers_united',
      256,
      Icons.agriculture,
      AppColors.healthColor,
    ),
    _Group(
      'group_young_mothers_support',
      67,
      Icons.child_care,
      AppColors.thriveColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          _groups.map((g) {
            return Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: g.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(g.icon, color: g.color, size: 22),
                ),
                title: Text(
                  t(g.nameKey),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text('${g.memberCount} ${t('members')}'),
                trailing: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(t('join'), style: const TextStyle(fontSize: 12)),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _Group {
  const _Group(this.nameKey, this.memberCount, this.icon, this.color);
  final String nameKey;
  final int memberCount;
  final IconData icon;
  final Color color;
}

class _CommunityFeed extends StatelessWidget {
  const _CommunityFeed({required this.t});
  final String Function(String) t;

  static const _posts = [
    _Post(
      'Sarah M.',
      'post_digital_skills_done',
      'time_2_hours_ago',
      AppColors.skillsColor,
    ),
    _Post(
      'Grace K.',
      'post_wholesale_order',
      'time_5_hours_ago',
      AppColors.earnColor,
    ),
    _Post(
      'Peace N.',
      'post_sacco_gulu',
      'time_1_day_ago',
      AppColors.financeColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          _posts.map((p) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: p.color.withValues(alpha: 0.12),
                          child: Text(
                            p.author[0],
                            style: TextStyle(
                              color: p.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                t(p.timeKey),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t(p.contentKey),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _FeedAction(Icons.favorite_border, t('like')),
                        const SizedBox(width: 16),
                        _FeedAction(Icons.chat_bubble_outline, t('comment')),
                        const SizedBox(width: 16),
                        _FeedAction(Icons.share_outlined, t('share')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _Post {
  const _Post(this.author, this.contentKey, this.timeKey, this.color);
  final String author;
  final String contentKey;
  final String timeKey;
  final Color color;
}

class _FeedAction extends StatelessWidget {
  const _FeedAction(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).hintColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
