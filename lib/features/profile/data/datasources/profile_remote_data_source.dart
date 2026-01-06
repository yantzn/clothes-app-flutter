import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';
import '../models/user_profile_dto.dart';
import '../../../onboarding/domain/entities/register_request.dart';

class ProfileRemoteDataSource {
  final ApiClient client;
  ProfileRemoteDataSource(this.client);

  static const _path = '/profile';

  Future<UserProfileDto> getProfile(String userId) async {
    // サーバ仕様に合わせてパスパラメータ形式 /profile/{userId} で取得
    final uri = client.resolve('$_path/$userId');
    final res = await client.get(uri, headers: {'Accept': 'application/json'});
    _ensureOk(res);
    final jsonBody = jsonDecode(res.body) as Map<String, dynamic>;
    return UserProfileDto.fromJson(jsonBody);
  }

  Future<UserProfileDto> patchProfile(UserProfileDto dto) async {
    final uri = client.resolve('$_path/${dto.userId}');
    // PATCH /api/profile/{userId} に path パラメータで指定
    final res = await client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(dto.toPatchJson()),
    );
    _ensureOk(res);
    // OpenAPIでは message + userId のみ返却のため、最新状態を再取得
    return getProfile(dto.userId);
  }

  /// 初期登録（オンボーディング）: POST /profile
  Future<Map<String, dynamic>> createProfile(RegisterRequest request) async {
    final uri = client.resolve(_path);
    final res = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );
    _ensureOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> putFamilies(
    String userId,
    List<Map<String, dynamic>> families,
  ) async {
    // putFamilies は廃止（PATCH /profile/{userId} に統一）
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}
