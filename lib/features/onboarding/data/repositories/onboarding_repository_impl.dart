import '../../domain/entities/register_request.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final ProfileRemoteDataSource remote;
  OnboardingRepositoryImpl(this.remote);

  @override
  Future<String> registerUser(RegisterRequest request) async {
    final json = await remote.createProfile(request);
    final id = (json['userId'] ?? json['id'] ?? '').toString();
    if (id.isEmpty) {
      throw Exception('userId not returned from server');
    }
    return id;
  }
}
