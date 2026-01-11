import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/domain/entities/profile.dart';
import '../../profile/domain/entities/family_member.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../../../core/network/api_client.dart';
import '../../profile/data/datasources/profile_remote_data_source.dart';
import '../../profile/data/repositories/profile_repository_impl.dart';
import '../../onboarding/presentation/onboarding_providers.dart';

/// Repository（DI）
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // とりあえず常にリモートを有効化（必要なら環境に応じて切替可能）
  final client = ApiClient();
  final ds = ProfileRemoteDataSource(client);
  return ProfileRepositoryImpl(ds);
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
    var userId = ref.read(userIdProvider);
    if (userId == null || userId.isEmpty) {
      // SharedPreferences から永続化済み userId を読み込み
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('userId');
      if (stored != null && stored.isNotEmpty) {
        userId = stored;
        // Provider にも反映
        ref.read(userIdProvider.notifier).set(userId);
      }
    }
    if (userId == null || userId.isEmpty) {
      // userId がない場合は取得不能としてエラー扱いにする（UI側でフォールバック）
      throw StateError('userId is not set');
    }
    return repo.loadProfile(userId);
  }

  Future<void> save(UserProfile profile) async {
    final repo = ref.read(profileRepositoryProvider);
    final updated = await repo.patchProfile(profile);
    state = AsyncData(updated);
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

  void setProfile(UserProfile profile) => state = profile;
}

/// 実効プロフィール（API成功ならサーバ値、失敗・未取得時はオンボーディング値で合成）
final effectiveProfileProvider = FutureProvider<UserProfile>((ref) async {
  try {
    // 優先: サーバから取得（依存を監視して更新を伝播）
    return await ref.watch(profileProvider.future);
  } catch (_) {
    // フォールバック: オンボーディングの入力値から合成
    final ob = ref.read(onboardingProvider);
    var userId = ref.read(userIdProvider);
    if (userId == null || userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
    }
    DateTime? birthday;
    try {
      final parts = ob.birthday.split('/');
      birthday = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      birthday = DateTime(2010, 1, 1);
    }

    // オンボーディング家族をドメインへ変換
    final families = ob.families.map((f) {
      DateTime fb;
      try {
        final parts = f.birthday.split('/');
        fb = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {
        fb = DateTime(2010, 1, 1);
      }
      return FamilyMember(name: f.name, birthday: fb, gender: f.gender);
    }).toList();

    return UserProfile(
      userId: userId,
      region: ob.region,
      birthday: birthday,
      gender: ob.gender.isNotEmpty ? ob.gender : 'male',
      notificationsEnabled: ob.notificationsEnabled,
      nickname: ob.nickname,
      families: families,
    );
  }
});
