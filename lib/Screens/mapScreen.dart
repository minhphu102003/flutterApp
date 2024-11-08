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
  double _zoomLevel = 14.0; // Mức zoom mặc định
  late MapController _mapController; // Khởi tạo MapController
  bool _mapReady = false; // Kiểm tra bản đồ đã sẵn sàng chưa
  TextEditingController _searchController = TextEditingController(); // Controller cho thanh tìm kiếm
  List<String> _suggestions = [];
  LatLng? _searchedLocation;
  List<LatLng> _routePolyline = []; // Danh sách điểm polyline của tuyến đường
  List<String> _routeInstructions = []; // Biến lưu thông tin hướng dẫn chi tiết

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
    // Gọi API Mapbox để lấy tọa độ từ địa chỉ
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
          _searchedLocation = latLng;
        });
        _mapController.move(latLng, _zoomLevel);
        _getRoute(_currentLocation, latLng);
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

  Future<void> _getRoute(LatLng start, LatLng destination) async {
    // Gọi API Mapbox Directions để lấy tuyến đường
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&steps=true&access_token=pk.eyJ1IjoibGV2cGh1b2N0aGluaCIsImEiOiJjbTJva29zcWkwZ256MnFzZnQwb2o0ZHI3In0.ohOhkig08r5vOgSMgb-WZg';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final route = data['routes'][0]['geometry']['coordinates'] as List;
        List<LatLng> polylinePoints =
            route.map((point) => LatLng(point[1], point[0])).toList();

        // Lấy thông tin hướng dẫn từ tất cả các bước
        final legs = data['routes'][0]['legs'] as List;
        List<String> instructions = [];
        for (var leg in legs) {
          final steps = leg['steps'] as List;
          for (var step in steps) {
            instructions.add(step['maneuver']['instruction'].toString());
          }
        }

        setState(() {
          _routePolyline = polylinePoints;
          _routeInstructions = instructions;
        });
      } else {
        print('No route data found in the response.');
      }
    } else {
      print('Failed to load route: ${response.statusCode}');
    }
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
                    ),
                    if (_routePolyline.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePolyline,
                            strokeWidth: 4.0,
                            color: Colors.blue, // Màu của tuyến đường
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          width: 30.0,
                          height: 30.0,
                          child: Icon(Icons.my_location, color: Colors.red),
                        ),
                        if (_searchedLocation != null)
                          Marker(
                            point: _searchedLocation!,
                            width: 30.0,
                            height: 30.0,
                            child: Icon(Icons.location_pin, color: Colors.blue),
                          ),
                      ],
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
                borderRadius: BorderRadius.circular(20),
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

          // Hiển thị hướng dẫn chi tiết
          if (_routeInstructions.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hướng dẫn chi tiết',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ..._routeInstructions.map((instruction) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(instruction),
                        )),
                  ],
                ),
              ),
            ),

          // Hiển thị gợi ý dưới thanh tìm kiếm
          Positioned(
            top: 100,
            left: 10,
            right: 10,
            child: _suggestions.isNotEmpty
                ? Container(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                    ),
                    color: Colors.white,
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
