import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/domain/entities/profile.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../../profile/data/mock_profile_repository.dart';

/// Repository（DI）
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

/// プロフィール本体（AsyncNotifier / autoDispose）
final profileProvider =
    AsyncNotifierProvider.autoDispose<ProfileNotifier, UserProfile>(
      ProfileNotifier.new,
    );

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.loadProfile();
  }

  Future<void> save(UserProfile p) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.saveProfile(p);
    // 最新状態の再読み込み
    state = AsyncData(p);
  }
}

/// 編集用（保持のみ）: NotifierProvider（autoDispose不要な単純保持）
final editingProfileProvider =
    NotifierProvider<EditingProfileNotifier, UserProfile?>(
      EditingProfileNotifier.new,
    );

class EditingProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => null;

  void setProfile(UserProfile p) => state = p;
}
