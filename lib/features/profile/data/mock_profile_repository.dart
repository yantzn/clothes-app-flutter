import 'dart:async';
import '../../profile/domain/entities/profile.dart';
import '../../profile/domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  UserProfile _cached = UserProfile(
    userId: "test-user-3",
    region: "指宿市",
    birthday: DateTime(1990, 1, 1),
    gender: "male",
    notificationsEnabled: true,
  );

  @override
  Future<UserProfile> loadProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _cached;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cached = profile;
  }
}
