import '../../domain/entities/home_today.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource ds;
  HomeRepositoryImpl(this.ds);

  @override
  Future<HomeToday> loadHomeToday(String userId) async {
    final dto = await ds.getHomeToday(userId);
    return dto.toEntity();
  }
}
