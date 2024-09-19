import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/models/additionalWeatherData.dart';
import 'package:flutter_application_1/models/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/dailyWeather.dart';
import '../models/hourlyWeather.dart';
import '../models/weather.dart';

class Weatherprovider with ChangeNotifier {
  String apiKey = Config.api_weather_key;
  late Weather weather;
  // late AdditionalWeatherData additionalWeatherData;
  LatLng? currentLocation;
  List<HourlyWeather> hourlyWeather = [];
  List<Dailyweather> dailyWeather = [];
  bool isLoading = false;
  bool isRequestError = false;
  bool isSearchError = false;
  bool isLocationSeviceEnable = false;
  LocationPermission? locationPermission;
  bool isCelsius = true;

  String get measurementUnit => isCelsius ? '°C' : '°F';

  Future<Position?> requestLocation(BuildContext context) async {
    isLocationSeviceEnable = await Geolocator.isLocationServiceEnabled();
    notifyListeners();

    if (!isLocationSeviceEnable) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location service disable')),
      );
      return Future.error('Location service are disable. ');
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      isLoading = false;
      notifyListeners();
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
        return Future.error('Location permissions are denied! ');
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location permissions are permanently denied, Please enable manually from app settings'),
      ));
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getWeatherData(
    BuildContext context, {
    bool notify = false,
  }) async {
    isLoading = true;
    isRequestError = false;
    isSearchError = false;
    if (notify) notifyListeners();

    Position? locData = await requestLocation(context);

    if (locData == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      currentLocation = LatLng(locData.latitude, locData.longitude);
      await getCurrentWeather(currentLocation!);
      await getDailyWeather(currentLocation!);
      await getHourlyWeather(currentLocation!);
    } catch (e) {
      print(e);
      isRequestError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ! Check ok
  Future<void> getCurrentWeather(LatLng location) async {
    Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey',
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      weather = Weather.fromJson(extractedData);
      print('Fetched Weather for: ${weather.city}/${weather.countryCode}');
    } catch (error) {
      print(error);
      isLoading = false;
      this.isRequestError = true;
    }
  }

  Future<void> getDailyWeather(LatLng location) async {
    int count = 7;
    isLoading = true;
    notifyListeners();

    Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast/daily?lat=${location.latitude}&lon=${location.longitude}&cnt=$count&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        List dailyList = extractedData['list'];
        dailyWeather =
            dailyList.map((item) => Dailyweather.fromDailyJson(item)).toList();
        isLoading = false;
        print('Fetch Daily Weather for: ${location.latitude}/${location.longitude}');
      } else {
        isLoading = false;
        throw Exception('Failed to load weather data');
      }
    } catch (error) {
      isLoading = false;
      print(error);
      isRequestError = true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> getHourlyWeather(LatLng location) async {
    int count = 24;
    isLoading = true;
    notifyListeners();

    Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&cnt=$count&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        List hourlyList = extractedData['list']; // 'list' instead of 'hourly'

        hourlyWeather = hourlyList
            .map((item) => HourlyWeather.fromJson(item))
            .toList()
            .take(24) // Take the first 24 hours
            .toList();

        isLoading = false;
        print('Fetch Daily Weather for: ${location.latitude}/${location.longitude}');
      } else {
        throw Exception('Failed to load hourly weather data');
      }
    } catch (error) {
      isLoading = false;
      print(error);
      isRequestError = true;
    } finally {
      notifyListeners();
    }
  }

  Future<GeocodeData?> locationToLatLng(String location) async {
    try {
      print(location);
      Uri url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$location&limit=5&appid=$apiKey',
      );
      final http.Response response = await http.get(url);
      if (response.statusCode != 200) return null;
      return GeocodeData.fromJson(
        jsonDecode(response.body)[0] as Map<String, dynamic>,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> searchWeather(String location) async {
    isLoading = true;
    notifyListeners();
    isRequestError = false;
    print('Search');

    try {
      GeocodeData? geocodeData;
      geocodeData = await locationToLatLng(location);
      if (geocodeData == null) throw Exception('Unable to find location! ');
      await getCurrentWeather(geocodeData.latLng);
      await getDailyWeather(geocodeData.latLng);
      await getHourlyWeather(geocodeData.latLng);

      weather.city = geocodeData.name;
    } catch (e) {
      print(e);
      isSearchError = true;
    } finally {
      isLoading = true;
      notifyListeners();
    }
  }

  void switchTempUnit() {
    isCelsius = !isCelsius;
    notifyListeners();
  }
}
