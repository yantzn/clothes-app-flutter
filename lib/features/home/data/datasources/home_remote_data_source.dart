import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';
import '../models/home_today_dto.dart';

class HomeRemoteDataSource {
  final ApiClient client;
  HomeRemoteDataSource(this.client);

  Future<HomeTodayDto> getHomeToday(String userId) async {
    // Base URLに `/api` が含まれているため、ここでは `/home` のみ指定
    final uri = client.resolve('/home/$userId');
    final res = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw http.ClientException('Failed to load home: ${res.statusCode}');
    }
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return HomeTodayDto.fromJson(jsonMap);
  }
}
