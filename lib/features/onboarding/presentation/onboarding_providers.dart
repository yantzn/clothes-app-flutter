// lib/features/onboarding/presentation/onboarding_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/family_member_request.dart';
import '../domain/entities/register_request.dart';
import '../domain/repositories/onboarding_repository.dart';
import '../domain/usecases/register_user.dart';
import '../../../core/network/api_client.dart';
import '../../profile/data/datasources/profile_remote_data_source.dart';
import '../data/repositories/onboarding_repository_impl.dart';

/// =================================================================
///  Repository Provider
/// =================================================================
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  // デフォルトはリモートAPIへ接続。
  final client = ApiClient();
  final ds = ProfileRemoteDataSource(client);
  return OnboardingRepositoryImpl(ds);
});

/// =================================================================
///  UseCase Provider
/// =================================================================
final registerUserProvider = Provider<RegisterUser>((ref) {
  final repo = ref.read(onboardingRepositoryProvider);
  return RegisterUser(repo);
});

/// =================================================================
///  Onboarding State
/// =================================================================

class OnboardingState {
  final bool agreedTerms;
  final String nickname;
  final String region;
  final String birthday;
  final String gender;
  final List<FamilyMemberRequest> families;
  final bool notificationsEnabled;

  const OnboardingState({
    this.agreedTerms = false,
    this.nickname = "",
    this.region = "",
    this.birthday = "",
    this.gender = "male",
    this.families = const [],
    this.notificationsEnabled = false,
  });

  OnboardingState copyWith({
    bool? agreedTerms,
    String? nickname,
    String? region,
    String? birthday,
    String? gender,
    List<FamilyMemberRequest>? families,
    bool? notificationsEnabled,
  }) {
    return OnboardingState(
      agreedTerms: agreedTerms ?? this.agreedTerms,
      nickname: nickname ?? this.nickname,
      region: region ?? this.region,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      families: families ?? this.families,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// =================================================================
///  Onboarding Controller（Notifier ベース）
/// =================================================================

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void setAgreedTerms(bool v) => state = state.copyWith(agreedTerms: v);

  void setNickname(String v) => state = state.copyWith(nickname: v);

  void setRegion(String v) => state = state.copyWith(region: v);

  void setBirthday(String v) => state = state.copyWith(birthday: v);

  void setGender(String v) => state = state.copyWith(gender: v);

  void addFamily(FamilyMemberRequest f) =>
      state = state.copyWith(families: [...state.families, f]);

  void removeFamily(int index) {
    final list = [...state.families]..removeAt(index);
    state = state.copyWith(families: list);
  }

  void updateFamily(int index, FamilyMemberRequest newData) {
    final list = [...state.families];
    list[index] = newData;
    state = state.copyWith(families: list);
  }

  void setNotificationsEnabled(bool v) =>
      state = state.copyWith(notificationsEnabled: v);

  RegisterRequest toRequest() {
    return RegisterRequest(
      nickname: state.nickname,
      region: state.region,
      birthday: state.birthday,
      gender: state.gender,
      families: state.families,
      notificationsEnabled: state.notificationsEnabled,
    );
  }

  Future<String> register() async {
    final usecase = ref.read(registerUserProvider);
    return await usecase(toRequest());
  }

  void reset() => state = const OnboardingState();
}

/// =================================================================
///  Provider
/// =================================================================

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

/// =================================================================
///  userId Provider (Notifier ベースに変更: StateProvider が未定義エラーのため)
/// =================================================================

class UserIdController extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
  void reset() => state = null;
}

final userIdProvider = NotifierProvider<UserIdController, String?>(
  UserIdController.new,
);
