import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterApp/config.dart';
import '../helper/appConfig.dart';

class LocationService {
  static const String apiKey = Config.api_opencage_key;
  static const String baseOpenCage = AppConfig.baseOpenCage;

  static Future<String> fetchAddress(double latitude, double longitude) async {
    final url = Uri.parse(
        '$baseOpenCage?q=$latitude,$longitude&key=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];
        if (results.isNotEmpty) {
          return results[0]['formatted']; // Lấy địa chỉ từ `formatted`.
        }
        return 'No address found';
      } else {
        return 'Failed to fetch address';
      }
    } catch (e) {
      return 'Error fetching address';
    }
  }
}
