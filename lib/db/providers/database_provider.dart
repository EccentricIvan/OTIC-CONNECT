import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../daos/user_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final userDaoProvider = Provider<UserDao>((ref) {
  return ref.watch(appDatabaseProvider).userDao;
});

/// Single source of truth for the local user's profile, used by
/// home_screen.dart and profile_screen.dart.
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(userDaoProvider).watchUser();
});
