import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/learn/learn_hub_screen.dart';
import '../../features/earn/marketplace/marketplace_screen.dart';
import '../../features/earn/financial/financial_hub_screen.dart';
import '../../features/grow/mentorship/mentorship_screen.dart';
import '../../features/grow/jobs/jobs_screen.dart';
import '../../features/grow/skills/skills_screen.dart';
import '../../features/thrive/health/health_screen.dart';
import '../../features/thrive/community/community_screen.dart';
import '../../features/thrive/wellbeing/wellbeing_screen.dart';
import '../../features/ai_chat/ai_chat_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final hasProfileProvider = FutureProvider<bool>((ref) async {
  // TODO: check local database for existing profile
  return false;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    redirect: (context, state) async {
      if (state.matchedLocation == '/onboarding') return null;
      try {
        final hasProfile = await ref.read(hasProfileProvider.future);
        if (!hasProfile) return '/onboarding';
      } catch (_) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // ── Core tabs ──
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/learn', builder: (_, __) => const LearnHubScreen()),
          GoRoute(
              path: '/marketplace',
              builder: (_, __) => const MarketplaceScreen()),
          GoRoute(
              path: '/community',
              builder: (_, __) => const CommunityScreen()),

          // ── Earn pillar ──
          GoRoute(
              path: '/financial',
              builder: (_, __) => const FinancialHubScreen()),

          // ── Grow pillar ──
          GoRoute(
              path: '/mentorship',
              builder: (_, __) => const MentorshipScreen()),
          GoRoute(path: '/jobs', builder: (_, __) => const JobsScreen()),
          GoRoute(
              path: '/skills', builder: (_, __) => const SkillsScreen()),

          // ── Thrive pillar ──
          GoRoute(
              path: '/health', builder: (_, __) => const HealthScreen()),
          GoRoute(
              path: '/wellbeing',
              builder: (_, __) => const WellbeingScreen()),

          // ── Tools ──
          GoRoute(
              path: '/ai-chat', builder: (_, __) => const AiChatScreen()),
          GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen()),
          GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
