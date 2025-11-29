import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// 現在地の座標取得
  static Future<Position> getPosition() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      await Geolocator.openLocationSettings();
      throw Exception("位置情報サービスが無効です");
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw Exception("位置情報の許可が必要です");
      }
    }

    if (perm == LocationPermission.deniedForever) {
      throw Exception("位置情報の許可が恒久的に拒否されています");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  /// 緯度経度 → 市区町村名へ変換
  static Future<String> toCity(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    final place = placemarks.first;

    return place.locality ?? place.subAdministrativeArea ?? "地域が取得できませんでした";
  }

  /// 現在地 → 市区町村名（ワンアクション）
  static Future<String> getCurrentCity() async {
    final pos = await getPosition();
    return toCity(pos.latitude, pos.longitude);
  }
}
