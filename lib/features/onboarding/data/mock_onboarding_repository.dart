// lib/features/onboarding/data/mock_onboarding_repository.dart

import 'dart:math';

import '../domain/entities/register_request.dart';
import '../domain/repositories/onboarding_repository.dart';

/// モック実装：API の代わりに userId をランダム生成して返す
class MockOnboardingRepository implements OnboardingRepository {
  @override
  Future<String> registerUser(RegisterRequest request) async {
    // モックなので少し遅延させる
    await Future.delayed(const Duration(milliseconds: 800));

    // デバッグログ（本番では削除）
    // ignore: avoid_print
    print("Mock registerUser() called with:");
    print(request.toJson());

    // userId をランダムで生成
    final randomId = Random().nextInt(999999).toString().padLeft(6, "0");

    return "mock-user-$randomId";
  }
}
