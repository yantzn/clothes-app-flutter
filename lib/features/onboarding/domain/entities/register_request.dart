import 'family_member_request.dart';

class RegisterRequest {
  final String nickname;
  final String region;
  final String birthday; // YYYY-MM-DD
  final String gender;
  final List<FamilyMemberRequest> families;
  final bool notificationsEnabled;

  RegisterRequest({
    required this.nickname,
    required this.region,
    required this.birthday,
    required this.gender,
    required this.families,
    required this.notificationsEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      "nickname": nickname,
      "region": region,
      "birthday": birthday,
      "gender": gender,
      "families": families.map((f) => f.toJson()).toList(),
      "notificationsEnabled": notificationsEnabled,
    };
  }
}
