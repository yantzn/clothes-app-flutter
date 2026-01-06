import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_dto.dart';

String _toApiGender(String g) {
  final v = g.trim().toLowerCase();
  switch (v) {
    case 'male':
    case '男性':
      return 'male';
    case 'female':
    case '女性':
      return 'female';
    case 'other':
    case 'その他':
      return 'other';
    default:
      return 'other';
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  ProfileRepositoryImpl(this.remote);

  @override
  Future<UserProfile> loadProfile(String userId) async {
    final dto = await remote.getProfile(userId);
    return dto.toEntity();
  }

  @override
  Future<UserProfile> patchProfile(UserProfile profile) async {
    final families = profile.families
        .map(
          (f) => {
            'name': f.name,
            'birthday':
                '${f.birthday.year.toString().padLeft(4, '0')}/${f.birthday.month.toString().padLeft(2, '0')}/${f.birthday.day.toString().padLeft(2, '0')}',
            'gender': _toApiGender(f.gender),
          },
        )
        .toList();

    final dto = UserProfileDto(
      userId: profile.userId,
      region: profile.region,
      birthday:
          '${profile.birthday.year.toString().padLeft(4, '0')}/${profile.birthday.month.toString().padLeft(2, '0')}/${profile.birthday.day.toString().padLeft(2, '0')}',
      gender: _toApiGender(profile.gender),
      notificationsEnabled: profile.notificationsEnabled,
      nickname: profile.nickname,
      family: families,
    );
    final res = await remote.patchProfile(dto);
    return res.toEntity();
  }
}
