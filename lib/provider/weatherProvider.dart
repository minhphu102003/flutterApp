import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/models/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/dailyWeather.dart';
import '../models/hourlyWeather.dart';
import '../models/weather.dart';

// Lớp Weatherprovider dùng để quản lý dữ liệu thời tiết và trạng thái của ứng dụng
class Weatherprovider with ChangeNotifier {
  String apiKey = Config.api_weather_key; // Khóa API để truy cập dữ liệu thời tiết
  late Weather weather; // Đối tượng Weather chứa thông tin thời tiết hiện tại
  LatLng? currentLocation; // Vị trí hiện tại
  List<HourlyWeather> hourlyWeather = []; // Danh sách thời tiết theo giờ
  List<Dailyweather> dailyWeather = []; // Danh sách thời tiết theo ngày
  bool isLoading = false; // Trạng thái tải dữ liệu
  bool isRequestError = false; // Kiểm tra lỗi yêu cầu dữ liệu
  bool isSearchError = false; // Kiểm tra lỗi tìm kiếm
  bool isLocationSeviceEnable = false; // Kiểm tra xem dịch vụ vị trí có được bật không
  LocationPermission? locationPermission; // Quyền truy cập vị trí
  bool isCelsius = true; // Kiểm tra đơn vị nhiệt độ

  String get measurementUnit => isCelsius ? '°C' : '°F'; // Đơn vị đo nhiệt độ

  // Yêu cầu quyền truy cập vị trí và kiểm tra dịch vụ vị trí
  Future<Position?> requestLocation(BuildContext context) async {
    isLocationSeviceEnable = await Geolocator.isLocationServiceEnabled();
    notifyListeners();

    if (!isLocationSeviceEnable) {
      // Thông báo nếu dịch vụ vị trí bị tắt
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location service disable')),
      );
      return Future.error('Location service are disable.');
    }

    locationPermission = await Geolocator.checkPermission();
    // Kiểm tra và yêu cầu quyền truy cập vị trí
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

    // Kiểm tra quyền truy cập vị trí bị từ chối vĩnh viễn
    if (locationPermission == LocationPermission.deniedForever) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location permissions are permanently denied, Please enable manually from app settings'),
      ));
    }
    // Lấy vị trí hiện tại
    return await Geolocator.getCurrentPosition();
  }

  // Lấy dữ liệu thời tiết
  Future<void> getWeatherData(BuildContext context, {bool notify = false}) async {
    isLoading = true; // Bắt đầu quá trình tải
    isRequestError = false;
    isSearchError = false;
    if (notify) notifyListeners();

    Position? locData = await requestLocation(context); // Yêu cầu vị trí

    if (locData == null) {
      isLoading = false;
      notifyListeners();
      return; // Nếu không có vị trí, thoát khỏi hàm
    }

    try {
      // Lưu vị trí và lấy dữ liệu thời tiết
      currentLocation = LatLng(locData.latitude, locData.longitude);
      await getCurrentWeather(currentLocation!);
      await getDailyWeather(currentLocation!);
      await getHourlyWeather(currentLocation!);
    } catch (e) {
      print(e);
      isRequestError = true; // Ghi nhận lỗi yêu cầu
    } finally {
      isLoading = false; // Kết thúc quá trình tải
      notifyListeners();
    }
  }

  // Lấy thời tiết hiện tại
  Future<void> getCurrentWeather(LatLng location) async {
    Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&units=metric&appid=$apiKey&lang=vi',
    );
    try {
      final response = await http.get(url); // Gửi yêu cầu đến API
      final extractedData = json.decode(response.body) as Map<String, dynamic>; // Giải mã JSON
      weather = Weather.fromJson(extractedData); // Tạo đối tượng Weather từ dữ liệu
      print('Fetched Weather for: ${weather.city}/${weather.countryCode}');
    } catch (error) {
      print(error);
      isLoading = false; // Kết thúc quá trình tải
      this.isRequestError = true; // Ghi nhận lỗi yêu cầu
    }
  }

  // Lấy thời tiết theo ngày
  Future<void> getDailyWeather(LatLng location) async {
    int count = 7; // Số lượng ngày để lấy
    isLoading = true; // Bắt đầu quá trình tải
    notifyListeners();

    Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast/daily?lat=${location.latitude}&lon=${location.longitude}&cnt=$count&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>; // Giải mã JSON
        List dailyList = extractedData['list'];
        // Chuyển đổi danh sách thời tiết theo ngày thành danh sách đối tượng Dailyweather
        dailyWeather =
            dailyList.map((item) => Dailyweather.fromDailyJson(item)).toList();
        isLoading = false; // Kết thúc quá trình tải
        print('Fetch Daily Weather for 1: ${location.latitude}/${location.longitude}');
      } else {
        isLoading = false;
        throw Exception('Failed to load weather data'); // Lỗi nếu không thể lấy dữ liệu
      }
    } catch (error) {
      isLoading = false; // Kết thúc quá trình tải
      print(error);
      isRequestError = true; // Ghi nhận lỗi yêu cầu
    } finally {
      notifyListeners();
    }
  }

  // Lấy thời tiết theo giờ
  Future<void> getHourlyWeather(LatLng location) async {
    int count = 24; // Số lượng giờ để lấy
    isLoading = true; // Bắt đầu quá trình tải
    notifyListeners();

    Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&cnt=$count&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>; // Giải mã JSON
        List hourlyList = extractedData['list']; // Danh sách thời tiết theo giờ

        // Chuyển đổi danh sách thời tiết theo giờ thành danh sách đối tượng HourlyWeather
        hourlyWeather = hourlyList
            .map((item) => HourlyWeather.fromJson(item))
            .toList()
            .take(24) // Lấy 24 giờ đầu tiên
            .toList();

        isLoading = false; // Kết thúc quá trình tải
        print('Fetch Daily Weather for: ${location.latitude}/${location.longitude}');
      } else {
        throw Exception('Failed to load hourly weather data'); // Lỗi nếu không thể lấy dữ liệu
      }
    } catch (error) {
      isLoading = false; // Kết thúc quá trình tải
      print(error);
      isRequestError = true; // Ghi nhận lỗi yêu cầu
    } finally {
      notifyListeners();
    }
  }

  // Tìm vị trí từ tên
  Future<GeocodeData?> locationToLatLng(String location) async {
    try {
      print(location);
      Uri url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$location&limit=5&appid=$apiKey',
      );
      final http.Response response = await http.get(url);
      if (response.statusCode != 200) return null; // Nếu không thành công, trả về null
      return GeocodeData.fromJson(
        jsonDecode(response.body)[0] as Map<String, dynamic>, // Chuyển đổi JSON thành GeocodeData
      );
    } catch (e) {
      print(e);
      return null; // Trả về null nếu có lỗi
    }
  }

  // Tìm kiếm thời tiết theo vị trí
  Future<void> searchWeather(String location) async {
    isLoading = true; // Bắt đầu quá trình tải
    notifyListeners();
    isRequestError = false;
    print('Search');

    try {
      GeocodeData? geocodeData;
      geocodeData = await locationToLatLng(location); // Lấy tọa độ từ tên vị trí
      if (geocodeData == null) throw Exception('Unable to find location! '); // Nếu không tìm thấy vị trí, báo lỗi
      await getCurrentWeather(geocodeData.latLng); // Lấy thời tiết hiện tại
      await getDailyWeather(geocodeData.latLng); // Lấy thời tiết theo ngày
      await getHourlyWeather(geocodeData.latLng); // Lấy thời tiết theo giờ

      weather.city = geocodeData.name; // Cập nhật tên thành phố
    } catch (e) {
      print(e);
      isSearchError = true; // Ghi nhận lỗi tìm kiếm
    } finally {
      isLoading = false; // Kết thúc quá trình tải
      notifyListeners();
    }
  }

  // Chuyển đổi giữa độ Celsius và độ Fahrenheit
  void switchTempUnit() {
    isCelsius = !isCelsius; // Đảo ngược trạng thái
    notifyListeners();
  }
}
