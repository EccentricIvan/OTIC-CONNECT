import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasProfile = prefs.getBool('has_profile') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        hasProfileProvider.overrideWith((ref) => hasProfile),
      ],
      child: const OticConnectApp(),
    ),
  );
}
