import 'package:flutter/material.dart';
import 'package:flutterApp/widgets/mapSample.dart';
import 'package:flutterApp/widgets/buttonWeather.dart';
import 'package:flutterApp/Screens/homeScreen.dart';
import 'package:flutterApp/bottom/bottomnav.dart';
import 'package:flutterApp/bottom/key.dart';
import 'package:flutterApp/bottom/profile.dart';
import 'package:flutterApp/widgets/support_widget.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  LatLng _currentLocation = LatLng(37.7749, -122.4194); // Vị trí mặc định
  bool _locationLoaded = false;
  double _zoomLevel = 19.5; // Mức zoom mặc định
  late MapController _mapController; // Khởi tạo MapController
  bool _mapReady = false; // Kiểm tra bản đồ đã sẵn sàng chưa
  TextEditingController _searchController =
      TextEditingController(); // Controller cho thanh tìm kiếm
  List<String> _suggestions = []; // Danh sách gợi ý tự động hoàn thành

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // Khởi tạo controller
    _getCurrentLocation(); // Lấy vị trí hiện tại khi bắt đầu
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra dịch vụ vị trí có bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Kiểm tra quyền truy cập vị trí
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Lấy vị trí hiện tại
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationLoaded = true;
        // Di chuyển bản đồ sau khi sẵn sàng
        if (_mapReady) {
          _mapController.move(_currentLocation, _zoomLevel);
        }
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    // Gọi API Mapbox để lấy toạ độ từ địa chỉ
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=pk.eyJ1IjoibGV2cGh1b2N0aGluaCIsImEiOiJjbTJva29zcWkwZ256MnFzZnQwb2o0ZHI3In0.ohOhkig08r5vOgSMgb-WZg';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['features'].isNotEmpty) {
        final firstResult = data['features'][0];
        final coordinates = firstResult['geometry']['coordinates'];
        final latLng = LatLng(coordinates[1], coordinates[0]);

        // Di chuyển bản đồ tới vị trí đã tìm thấy
        setState(() {
          _currentLocation = latLng;
        });
        _mapController.move(latLng, _zoomLevel);
      } else {
        print('No results found for the address.');
      }
    } else {
      print('API request failed: ${response.statusCode}');
    }
  }

  Future<void> _selectSuggestion(String suggestion) async {
    // Khi người dùng chọn gợi ý, tìm kiếm và di chuyển bản đồ tới vị trí tương ứng
    _searchController.text = suggestion;
    _suggestions.clear();
    _searchLocation(suggestion);
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      // Gọi API để lấy gợi ý
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=pk.eyJ1IjoibGV2cGh1b2N0aGluaCIsImEiOiJjbTJva29zcWkwZ256MnFzZnQwb2o0ZHI3In0.ohOhkig08r5vOgSMgb-WZg';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _suggestions = data['features']
              .map<String>((item) => item['place_name'].toString())
              .toList();
        });
      } else {
        print('API request failed: ${response.statusCode}');
      }
    } else {
      setState(() {
        _suggestions.clear();
      });
    }
  }

  // Định nghĩa hàm _onWeatherButtonPressed
  void _onWeatherButtonPressed() {
    // Lấy kích thước màn hình
    final screenSize = MediaQuery.of(context).size;
    // Tính toán vị trí của button
    final buttonOffset = Offset(10.0, screenSize.height * 0.15);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          // Điều chỉnh vị trí bắt đầu phóng theo buttonOffset
          var scaleAnimation = Tween<double>(begin: begin, end: end).animate(
            CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
          );

          var opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
          );

          // Tính toán offset cho màn hình mới
          var scaleTransform = Matrix4.identity()..scale(scaleAnimation.value);

          return Transform(
            transform: scaleTransform,
            alignment:
                Alignment.topLeft, // Hoặc điều chỉnh để phù hợp với yêu cầu
            child: FadeTransition(
              opacity: opacityAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _locationLoaded
              ? FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: _zoomLevel,
                    onMapReady: () {
                      setState(() {
                        _mapReady = true;
                        _mapController.move(_currentLocation, _zoomLevel);
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGV2cGh1b2N0aGluaCIsImEiOiJjbTJva29zcWkwZ256MnFzZnQwb2o0ZHI3In0.ohOhkig08r5vOgSMgb-WZg",
                      additionalOptions: const {
                        'accessToken':
                            'pk.eyJ1IjoibGV2cGh1b2N0aGluaCIsImEiOiJjbTJva29zcWkwZ256MnFzZnQwb2o0ZHI3In0.ohOhkig08r5vOgSMgb-WZg',
                        'id': 'mapbox.mapbox-streets-v8',
                      },
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),

          // Thanh tìm kiếm đặt ở trên
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // Góc bo tròn
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm địa chỉ...',
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        _searchLocation(_searchController.text);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _suggestions.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Hiển thị gợi ý dưới thanh tìm kiếm
          Positioned(
            top: 100, // Điều chỉnh để gợi ý xuất hiện dưới thanh tìm kiếm
            left: 10,
            right: 10,
            child: _suggestions.isNotEmpty
                ? Container(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                    ),
                    color: Colors.white,
                    width: double.infinity,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_suggestions[index]),
                          onTap: () => _selectSuggestion(_suggestions[index]),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ),

          // Icon thời tiết đặt dưới thanh tìm kiếm
          Positioned(
            top: 160, // Đưa icon xuống dưới thanh tìm kiếm
            left: 20,
            child: _suggestions
                    .isEmpty // Only show the icon if there are no suggestions
                ? Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue, // Màu nền cho icon
                      shape: BoxShape.circle, // Bo tròn
                    ),
                    child: IconButton(
                      icon: Icon(Icons.cloudy_snowing,
                          size: 30, color: Colors.white), // Icon thời tiết
                      onPressed: _onWeatherButtonPressed,
                    ),
                  )
                : SizedBox.shrink(), // Hide the icon when there are suggestions
          ),

          // Nút nổi (zoom và vị trí hiện tại)
          Positioned(
            bottom: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  onPressed: () {
                    setState(() {
                      _zoomLevel++;
                      _mapController.move(_currentLocation, _zoomLevel);
                    });
                  },
                  child: Icon(Icons.zoom_in),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  onPressed: () {
                    setState(() {
                      _zoomLevel--;
                      _mapController.move(_currentLocation, _zoomLevel);
                    });
                  },
                  child: Icon(Icons.zoom_out),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "location",
                  onPressed: () {
                    _getCurrentLocation();
                  },
                  child: Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
