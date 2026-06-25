import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _nameController = TextEditingController();
  String? _role;
  String? _location;
  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (_page < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_profile', true);
    await prefs.setString('user_name', _nameController.text.trim());
    if (_role != null) await prefs.setString('user_role', _role!);
    if (_location != null) await prefs.setString('user_location', _location!);
    ref.read(hasProfileProvider.notifier).state = true;
    if (mounted) context.go('/');
  }

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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i
                            ? AppColors.primary
                            : Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _WelcomePage(controller: _nameController),
                    _RolePage(
                      selected: _role,
                      location: _location,
                      onRole: (r) => setState(() => _role = r),
                      onLocation: (l) => setState(() => _location = l),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Row(
                  children: [
                    if (_page > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _back,
                          child: const Text('Back'),
                        ),
                      ),
                    if (_page > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _next,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_page < 1
                                ? 'Continue'
                                : 'Start your journey'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Image.asset(
            'assets/branding/otic_logo.png',
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to\nOtic Connect',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Your digital companion for learning, earning, growing, and thriving. '
            'Works online and offline — your progress is always safe.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            "What's your name?",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePage extends StatelessWidget {
  const _RolePage({
    required this.selected,
    required this.location,
    required this.onRole,
    required this.onLocation,
  });
  final String? selected;
  final String? location;
  final void Function(String?) onRole;
  final void Function(String?) onLocation;

  static const _roles = [
    ('Entrepreneur', Icons.rocket_launch, 'I run or want to start a business'),
    ('Farmer', Icons.agriculture, 'I work in agriculture or agribusiness'),
    ('Student', Icons.school, 'I am currently studying or in training'),
    ('Job Seeker', Icons.work_outline, 'I am looking for employment'),
    ('Community Leader', Icons.groups, 'I lead or organize in my community'),
    ('Artisan / Creator', Icons.palette, 'I create handmade goods or crafts'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text('About you',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(
            'This helps us personalise your experience with relevant opportunities and resources.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text('What best describes you?',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ..._roles.map((r) {
            final isSelected = selected == r.$1;
            return GestureDetector(
              onTap: () => onRole(selected == r.$1 ? null : r.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      r.$2,
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).hintColor,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.$1,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                            ),
                          ),
                          Text(
                            r.$3,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('Where are you based?',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          TextField(
            onChanged: onLocation,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'e.g. Kampala, Mukono, Mbale',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

