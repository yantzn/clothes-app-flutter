import '../../domain/entities/profile.dart';
import '../../domain/entities/family_member.dart';

class UserProfileDto {
  final String userId;
  final String region;
  final String birthday; // YYYY/MM/DD 形式を想定
  final String gender;
  final bool? notificationsEnabled; // PATCHでは省略可能に
  final String nickname;
  final List<Map<String, dynamic>> family; // DTOでは軽量にMap保持

  const UserProfileDto({
    required this.userId,
    required this.region,
    required this.birthday,
    required this.gender,
    this.notificationsEnabled,
    this.nickname = '',
    this.family = const [],
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    // 柔軟にキー名を許容（backendの差異に備える）
    final userId = (json['userId'] ?? json['id'] ?? '').toString();
    final region = (json['region'] ?? '').toString();
    final birthdayStr = (json['birthday'] ?? '').toString();
    final gender = (json['gender'] ?? 'male').toString();
    final notificationsEnabled = json['notificationsEnabled'] == null
        ? null
        : (json['notificationsEnabled'] == true);
    final nickname = (json['nickname'] ?? '').toString();
    // family は null/型ゆらぎに強く、要素を Map<String,dynamic> に正規化
    final List<Map<String, dynamic>> family =
        (json['family'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];
    return UserProfileDto(
      userId: userId,
      region: region,
      birthday: birthdayStr,
      gender: gender,
      notificationsEnabled: notificationsEnabled,
      nickname: nickname,
      family: family,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId': userId,
      'region': region,
      'birthday': birthday,
      'gender': gender,
      'nickname': nickname,
    };
    if (notificationsEnabled != null) {
      map['notificationsEnabled'] = notificationsEnabled;
    }
    return map;
  }

  /// PATCH 用に、未設定（空文字やデフォルト）を省いてボディを構築
  Map<String, dynamic> toPatchJson() {
    final Map<String, dynamic> body = {};
    if (region.isNotEmpty) body['region'] = region;
    if (birthday.isNotEmpty) body['birthday'] = birthday;
    if (gender.isNotEmpty) body['gender'] = gender;
    // notificationsEnabled は指定されている場合のみ含める
    if (notificationsEnabled != null) {
      body['notificationsEnabled'] = notificationsEnabled;
    }
    if (nickname.isNotEmpty) body['nickname'] = nickname;
    if (family.isNotEmpty) body['family'] = family;
    return body;
  }

  UserProfile toEntity() {
    // 'YYYY/MM/DD' を DateTime に変換（不正時は現在日にフォールバック）
    DateTime parsed;
    try {
      final norm = birthday.replaceAll('-', '/');
      final parts = norm.split('/');
      parsed = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      parsed = DateTime.now();
    }

    // family をドメインに変換
    final families = family.map((m) {
      final name = (m['name'] ?? '').toString();
      final gender = (m['gender'] ?? 'male').toString();
      DateTime fb;
      try {
        final b = (m['birthday'] ?? '').toString();
        final norm = b.replaceAll('-', '/');
        final parts = norm.split('/');
        fb = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {
        fb = DateTime(2010, 1, 1);
      }
      return FamilyMember(name: name, birthday: fb, gender: gender);
    }).toList();

    return UserProfile(
      userId: userId,
      region: region,
      birthday: parsed,
      gender: gender,
      notificationsEnabled: notificationsEnabled ?? true,
      nickname: nickname,
      families: families,
    );
  }
}
