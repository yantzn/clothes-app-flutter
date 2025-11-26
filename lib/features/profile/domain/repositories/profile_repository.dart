import '../entities/profile.dart';

/// プロフィール情報の永続化を担う抽象リポジトリ
///
/// data 層で mock / API / ローカルDB などに差し替える
abstract class ProfileRepository {
  Future<UserProfile> loadProfile();

  Future<void> saveProfile(UserProfile profile);
}
