import 'package:flutter/material.dart';
import 'package:flutterApp/models/camera.dart';
import 'package:flutterApp/services/reportService.dart';
import 'package:flutterApp/utils/reportConverter.dart';
import 'package:flutterApp/widgets/reportMarker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/models/notification.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutterApp/helper/appConfig.dart';
import 'package:flutterApp/widgets/placeInfor.dart';
import 'package:flutterApp/utils/scaleMap.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MapDisplay extends StatefulWidget {
  final LatLng currentLocation;
  final List<Map<String, dynamic>> routePolylines;
  final MapController mapController;
  final bool mapReady;
  final void Function() onMapReady;
  final double markerSize;
  final void Function(TapPosition, LatLng) onMapTap;
  final List<Marker> additionalMarkers;
  final List<Place> places;
  final Function(LatLng start, LatLng destination) onDirectionPressed;
  final List<TrafficNotification> notifications;
  final double zoomLevel;
  final List<Camera> cameras;

  const MapDisplay({
    super.key,
    required this.currentLocation,
    required this.routePolylines,
    required this.mapController,
    required this.mapReady,
    required this.onMapReady,
    required this.onMapTap,
    this.additionalMarkers = const [],
    this.markerSize = AppConfig.markerSize,
    this.places = const [],
    required this.onDirectionPressed,
    this.notifications = const [],
    required this.zoomLevel,
    required this.cameras,
  });

  @override
  MapDisplayState createState() => MapDisplayState();
}

class MapDisplayState extends State<MapDisplay>
    with SingleTickerProviderStateMixin {
  int? _selectedMarkerIndex;
  bool firstRecommend = false;
  List<Map<String, dynamic>> previousRoutePolylines = [];
  Timer? _timer;
  List<TrafficNotification> notifications = [];
  bool displayImage = false;
  String baseMapDisplay = AppConfig.baseMapDisplay;
  bool _showCircle = true;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  late final ReportService _reportService;

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
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rippleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    notifications = widget.notifications;
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _showCircle = false;
        });
      }
    });
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        removeExpiredNotifications();
      }
    });
    _reportService = ReportService();
    _fetchInitialReports();
  }

  Future<List<TrafficNotification>> _fetchInitialReports() async {
    final DateTime endDate = DateTime.now();
    final DateTime now = DateTime.now();
    final DateTime startDate = endDate.subtract(const Duration(minutes: 30));

    try {
      final data = await _reportService.fetchAccountReport(
        startDate: startDate,
        endDate: endDate,
      );

      final List<TrafficNotification> filteredNotifications = [];
      for (final report in data.data) {
        final bool startsWithT = report.typeReport.startsWith('T');
        final Duration difference = now.difference(report.timestamp);

        if (startsWithT) {
          if (difference.inMinutes <= 5) {
            filteredNotifications.add(convertReportToNotification(
                report,
                widget.currentLocation.latitude,
                widget.currentLocation.longitude));
          }
        } else {
          filteredNotifications.add(convertReportToNotification(
              report,
              widget.currentLocation.latitude,
              widget.currentLocation.longitude));
        }
      }
      return filteredNotifications;
    } catch (e) {
      debugPrint("Failed to load recent reports: $e");
      return [];
    }
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
    _rippleController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void showPlaceInfo(BuildContext context, Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return PlaceInfoWidget(
          place: place,
          currentLocation: widget.currentLocation,
          onDirectionPressed: widget.onDirectionPressed,
        );
      },
    );
  }

  void showYoutubeDialog(BuildContext context, String youtubeUrl) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Invalid YouTube URL"),
          content: Text("Cannot load video."),
        ),
      );
      return;
    }

    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(8),
        content: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
        ),
      ),
    ).then((_) {
      _controller.pause(); // Pause when dialog is closed
      _controller.dispose(); // Clean up
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> reportMarkers = List.generate(notifications.length, (index) {
      final report = notifications[index];
      final isSelected = _selectedMarkerIndex == index;
      final double baseSize = isSelected ? 50.0 : 36.0;
      const double scaleFactor = 1.2;
      final double scaledSize =
          baseSize * (widget.zoomLevel / 15 * scaleFactor).clamp(0.5, 2.0);

      return Marker(
        point: LatLng(report.latitude, report.longitude),
        width: scaledSize,
        height: scaledSize,
        child: ReportMarkerWidget(
          zoom: widget.zoomLevel,
          isSelected: isSelected,
          displayImage: displayImage,
          imageUrl: report.img,
          onTap: () {
            setState(() {
              _selectedMarkerIndex = isSelected ? null : index;
            });
          },
        ),
      );
    });

    String api = Config.api_mapbox_key;
    List<Marker> placeMarkers = widget.places.map((place) {
      IconData markerIcon;
      Color markerColor;

      switch (place.type) {
        case 'Restaurant':
          markerIcon = Icons.restaurant;
          markerColor = Colors.red;
          break;
        case 'Tourist destination':
          markerIcon = Icons.location_city;
          markerColor = Colors.blue;
          break;
        case 'Hotel':
          markerIcon = Icons.hotel;
          markerColor = Colors.green;
          break;
        case 'Museum':
          markerIcon = Icons.museum;
          markerColor = Colors.purple;
          break;
        default:
          markerIcon = Icons.location_on;
          markerColor = Colors.orangeAccent;
      }

      return Marker(
        point: LatLng(place.latitude, place.longitude),
        width: widget.markerSize,
        height: widget.markerSize,
        child: GestureDetector(
          onTap: () {
            showPlaceInfo(context, place);
          },
          child: Icon(
            markerIcon,
            color: markerColor, // Áp dụng màu sắc tương ứng
            size: 30,
          ),
        ),
      );
    }).toList();

    List<Marker> cameraMarkers = widget.cameras.map((camera) {
      return Marker(
        point: LatLng(camera.latitude, camera.longitude),
        width: widget.markerSize,
        height: widget.markerSize,
        child: GestureDetector(
          onTap: () {
            showYoutubeDialog(context, camera.link);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: camera.status
                      ? const Color.fromARGB(255, 242, 237, 216)
                          .withOpacity(0.8)
                      : const Color.fromARGB(255, 129, 108, 112)
                          .withOpacity(0.8),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.videocam,
              color: camera.status
                  ? const Color.fromARGB(255, 204, 181, 67)
                  : const Color(0xFFFF1744),
              size: 26,
            ),
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
          urlTemplate: "$baseMapDisplay?access_token=$api",
        ),
        if (widget.routePolylines.isNotEmpty)
          PolylineLayer(
            polylines: widget.routePolylines.map((route) {
              Color polylineColor;
              if (route['recommended'] == true && !firstRecommend) {
                polylineColor = Colors.blue;
                firstRecommend = true;
              } else if (route['recommended'] == false) {
                polylineColor = Colors.red;
              } else {
                polylineColor = const Color.fromARGB(255, 96, 141, 196);
              }
              return Polyline(
                points: route['coordinates'],
                strokeWidth: 4.0,
                color: polylineColor,
              );
            }).toList(),
          ),
        if (_showCircle)
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              final double progress = _rippleAnimation.value;
              final double radius =
                  calculateRadius(widget.zoomLevel) * 0.4 * (1 + progress);
              final double opacity = (1 - progress).clamp(0.0, 1.0);

              return CircleLayer(
                circles: [
                  CircleMarker(
                    point: widget.currentLocation,
                    color: Colors.blue.withOpacity(0.5 * opacity),
                    borderStrokeWidth: 0,
                    borderColor: Colors.transparent,
                    radius: radius,
                  ),
                ],
              );
            },
          ),
        MarkerLayer(
          key: ValueKey(_selectedMarkerIndex),
          markers: [
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
            ...cameraMarkers,
          ],
        ),
      ],
    );
  }
}
