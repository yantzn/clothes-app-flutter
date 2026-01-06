import '../../domain/entities/family_member.dart';

/// ユーザー／家族の基本プロフィール
class UserProfile {
  final String userId;
  final String region; // 例: "鹿児島 指宿市"
  final DateTime birthday;
  final String gender; // "male" / "female" / "other" など
  final bool notificationsEnabled;
  final String nickname;
  final List<FamilyMember> families;

  const UserProfile({
    required this.userId,
    required this.region,
    required this.birthday,
    required this.gender,
    required this.notificationsEnabled,
    this.nickname = '',
    this.families = const [],
  });

  UserProfile copyWith({
    String? userId,
    String? region,
    DateTime? birthday,
    String? gender,
    bool? notificationsEnabled,
    String? nickname,
    List<FamilyMember>? families,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      region: region ?? this.region,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      nickname: nickname ?? this.nickname,
      families: families ?? this.families,
    );
  }
}
