import '../repositories/onboarding_repository.dart';
import '../entities/register_request.dart';

class RegisterUser {
  final OnboardingRepository _repo;

  RegisterUser(this._repo);

  Future<String> call(RegisterRequest request) {
    return _repo.registerUser(request);
  }
}
