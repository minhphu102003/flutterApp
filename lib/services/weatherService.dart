import 'package:flutterApp/services/apiClient.dart';
import 'package:dio/dio.dart';

class WeatherService{
  final ApiClient _apiClient = ApiClient.instance;
  Future<Map<String, dynamic>> getSuggestion(double longitude, double latitude) async {
    try{
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(), 
      };
      Response response = await _apiClient.dio.get(
        '/weather/suggestion',
        queryParameters: queryParams
      );
      if(response.statusCode == 200){
        return response.data;
      }else{
        throw Exception('Failed to fetch weather suggestion');
      }
    }catch(e){
      print('Error fetching weather suggestion: $e');
      return {
        'success': false,
        'message':'Error fetching weather suggestion',
        'error': e.toString(),
      };
    }
  }
}