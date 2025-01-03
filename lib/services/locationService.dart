import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterApp/config.dart';

class LocationService {
  static const String apiKey = Config.api_opencage_key;

  static Future<String> fetchAddress(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$latitude,$longitude&key=$apiKey');
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
      print('Error fetching address: $e');
      return 'Error fetching address';
    }
  }
}
