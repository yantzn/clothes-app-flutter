import '../entities/home_today.dart';

abstract class HomeRepository {
  Future<HomeToday> loadHomeToday(String userId);
}
