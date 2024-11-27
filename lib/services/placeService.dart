import 'package:dio/dio.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/models/paginated_data.dart';
import './apiClient.dart';

class PlaceService {
  final ApiClient _apiClient = ApiClient.instance;
  // Function to fetch nearest places based on radius, type, limit, and page
  Future<PaginatedData<Place>> fetchNearestPlaces({
    required double longitude,
    required double latitude,
    int? radius = 20,   // Default radius is 20 km
    String? type,           // type is optional
    int? limit = 10,         // Default limit is 5 places
    int? page = 1,          // Default page is 1
    double? minStar,
    double? maxStar,
  }) async {
    try {
      // Build the query parameters for the GET request
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
        'page': page.toString(),
      };
      // Add 'type' to queryParams only if it's not null or empty
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (minStar != null) {
        queryParams['minStar'] = minStar.toString();
      }
      if (maxStar != null) {
        queryParams['maxStar'] = maxStar.toString();
      }
      // Sending GET request to the API
      Response response = await _apiClient.dio.get(
        '/place/nearest',
        queryParameters: queryParams, // Pass query parameters in the request
      );
      // If the response is successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the response body
        final jsonResponse = response.data as Map<String, dynamic>;

        // Return PaginatedData object containing the list of places
        return PaginatedData<Place>.fromJson(
          jsonResponse,
          (json) => Place.fromJson(json), // Convert each item in 'data' to Place object
        );
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      // Handle any errors (e.g., network issues)
      throw Exception('Error occurred: $e');
    }
  }

    // New function: Search places by name
  Future<PaginatedData<Place>> searchPlaces({
    required String name,
    int? limit = 10, // Default limit is 10
    int? page = 1,   // Default page is 1
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'name': name,
        'limit': limit.toString(),
        'page': page.toString(),
      };

      // Send GET request to search API
      Response response = await _apiClient.dio.get(
        '/place/search',
        queryParameters: queryParams,
      );

      // Parse and return PaginatedData if successful
      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;
        return PaginatedData<Place>.fromJson(
          jsonResponse,
          (json) => Place.fromJson(json),
        );
      } else {
        throw Exception('Failed to search places');
      }
    } catch (e) {
      // Handle errors
      throw Exception('Error occurred: $e');
    }
  }

  
}
