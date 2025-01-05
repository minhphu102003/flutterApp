import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/helper/location.dart';
import 'package:flutterApp/services/locationService.dart';
import 'package:flutterApp/screens/placeDetail.dart';
import 'package:flutterApp/models/notification.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutterApp/helper/appConfig.dart';

class MapDisplay extends StatefulWidget {
  final LatLng currentLocation;
  final List<Map<String, dynamic>> routePolylines;
  final MapController mapController;
  final bool mapReady;
  final void Function() onMapReady;
  final double markerSize;
  final void Function(TapPosition, LatLng) onMapTap;
  final List<Marker> additionalMarkers; // Danh sách marker tùy chỉnh
  final List<Place> places; // Thêm tham số places
  final Function(LatLng start, LatLng destination) onDirectionPressed;
  final List<TrafficNotification> notifications;

  const MapDisplay({
    super.key,
    required this.currentLocation,
    required this.routePolylines,
    required this.mapController,
    required this.mapReady,
    required this.onMapReady,
    required this.onMapTap,
    this.additionalMarkers = const [], // Khởi tạo danh sách rỗng
    this.markerSize = AppConfig.markerSize,
    this.places = const [],
    required this.onDirectionPressed,
    this.notifications = const [], // Khởi tạo danh sách places
  });

  @override
  MapDisplayState createState() => MapDisplayState();
}

class MapDisplayState extends State<MapDisplay> {
  String serverUrl = kIsWeb
      ? AppConfig.urlLocalUploadWed
      : AppConfig.urlLocalUploadAndroi;
  final double _imageSize = AppConfig.imageSize;
  final double _imageSizeClick = AppConfig.imageSizeClick;
  int? _selectedMarkerIndex;
  bool firstRecommend = false;
  List<Map<String, dynamic>> previousRoutePolylines = [];
  Timer? _timer;
  List<TrafficNotification> notifications = [];
  bool displayImage = false;
  String baseMapDisplay = AppConfig.baseMapDisplay;

  @override
  void didUpdateWidget(covariant MapDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routePolylines != oldWidget.routePolylines) {
      firstRecommend = false;
      previousRoutePolylines = widget.routePolylines;
    }
    if (widget.notifications != oldWidget.notifications) {
      notifications = widget.notifications;
    }
  }

  @override
  void initState() {
    super.initState();
    notifications = widget.notifications;
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        removeExpiredNotifications(); 
      }
    });
  }

  void addNotifications(TrafficNotification notification) {
    setState(() {
      widget.notifications.add(notification);
    });
  }

  void changeDisplayImage({bool? value}) {
    setState(() {
      displayImage = value ?? !displayImage;
    });
  }

  void removeExpiredNotifications() {
    DateTime currentTime = DateTime.now();
    if (mounted) {
      setState(() {
        widget.notifications.removeWhere((notification) {
          Duration diff = currentTime.difference(notification.timestamp);
          return diff.inMinutes > AppConfig.timeHideTrafficJam; 
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy Timer khi widget bị hủy
    super.dispose();
  }

  void showPlaceInfo(BuildContext context, Place place) {
    final distance = calculateDistance(
      widget.currentLocation,
      LatLng(place.latitude, place.longitude),
    );
    LatLng destination = LatLng(place.latitude, place.longitude);
    // Gọi API để lấy địa chỉ
    Future<String> addressFuture =
        LocationService.fetchAddress(place.latitude, place.longitude);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Image.network(
                  place.img,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder.png',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              // Tên của Place
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  place.name,
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16.0, color: Colors.grey),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: FutureBuilder<String>(
                        future: addressFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              'Fetching address...',
                              style:
                                  TextStyle(fontSize: 14.0, color: Colors.grey),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              'Error fetching address',
                              style:
                                  TextStyle(fontSize: 14.0, color: Colors.grey),
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              snapshot.data!,
                              style: const TextStyle(
                                  fontSize: 14.0, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            );
                          } else {
                            return const Text(
                              'No address found',
                              style:
                                  TextStyle(fontSize: 14.0, color: Colors.grey),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Type: ${place.type}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Distance: ${distance.toStringAsFixed(2)} km',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlaceDetailScreen(place: place),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                    IconButton(
                      onPressed: () {
                        widget.onDirectionPressed(
                            widget.currentLocation, destination);
                      },
                      icon: const Icon(Icons.directions),
                      color: Colors.blue,
                      iconSize: 28.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> reportMarkers = List.generate(notifications.length, (index) {
      final report = notifications[index];
      return Marker(
        point: LatLng(report.latitude, report.longitude),
        width: _imageSize, // Kích thước của marker
        height: _imageSize, // Kích thước của marker
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedMarkerIndex == index) {
                _selectedMarkerIndex = null; // Nếu đã chọn thì bỏ chọn
              } else {
                _selectedMarkerIndex = index;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: (_selectedMarkerIndex == index)
                ? _imageSizeClick
                : _imageSize, // Chỉ thay đổi kích thước của marker được chọn
            height: (_selectedMarkerIndex == index) ? _imageSizeClick : _imageSize,
            decoration: displayImage
                ? null // Không có BoxDecoration nếu hiển thị biểu tượng warning
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border:
                        Border.all(color: Colors.red, width: 3.0), // Viền đỏ
                    image: DecorationImage(
                      image: NetworkImage(report.img), // Hiển thị ảnh
                      fit: BoxFit.cover,
                    ),
                  ),
            child: displayImage
                ? Container(
                    width: _selectedMarkerIndex == index
                        ? 50.0
                        : 36.0, // Kích thước vùng chứa
                    height: _selectedMarkerIndex == index ? 50.0 : 36.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Hình tròn
                      border: Border.all(
                        color:
                            const Color.fromARGB(255, 253, 103, 73), // Màu viền
                        width: 3.0, // Độ dày viền
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 250, 113, 67)
                              .withOpacity(0.5), // Hiệu ứng đổ bóng
                          spreadRadius: 4, // Độ lan tỏa bóng
                          blurRadius: 6, // Độ mờ bóng
                          offset: const Offset(0, 3), // Độ lệch bóng
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.warning, // Biểu tượng warning
                        color: const Color.fromARGB(255, 238, 88, 42),
                        size: _selectedMarkerIndex == index ? 30.0 : 20.0,
                      ),
                    ),
                  )
                : null, // Không hiển thị `child` nếu có ảnh
          ),
        ),
      );
    });

    String api = Config.api_mapbox_key;
    List<Marker> placeMarkers = widget.places.map((place) {
      return Marker(
        point: LatLng(place.latitude, place.longitude),
        width: widget.markerSize,
        height: widget.markerSize,
        child: GestureDetector(
          onTap: () {
            showPlaceInfo(context, place);
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.orangeAccent, // Marker màu cam cho địa điểm
            size: 30,
          ),
        ),
      );
    }).toList();

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: widget.currentLocation,
        initialZoom: 16.0,
        onMapReady: widget.onMapReady,
        onTap: widget.onMapTap,
      ),
      children: [
        TileLayer(
          urlTemplate:
              "$baseMapDisplay?access_token=$api",
        ),
        if (widget.routePolylines.isNotEmpty)
          PolylineLayer(
            polylines: widget.routePolylines.map((route) {
              Color polylineColor;
              if (route['recommended'] == true && !firstRecommend) {
                polylineColor = Colors.blue;
                firstRecommend =
                    true;
              } else if (route['recommended'] == false) {
                // If it's not recommended, color it red
                polylineColor = Colors.red;
              } else {
                polylineColor = const Color.fromARGB(255, 96, 141, 196);
              }
              return Polyline(
                points: route['coordinates'], // Get coordinates
                strokeWidth: 4.0,
                color: polylineColor,
              );
            }).toList(),
          ),
        MarkerLayer(
          key: ValueKey(_selectedMarkerIndex),
          markers: [
            // Marker mặc định tại vị trí hiện tại
            Marker(
              point: widget.currentLocation,
              width: widget.markerSize,
              height: widget.markerSize,
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: widget.markerSize * 0.6,
              ),
            ),
            ...widget.additionalMarkers,
            ...placeMarkers,
            ...reportMarkers,
          ],
        ),
      ],
    );
  }
}
