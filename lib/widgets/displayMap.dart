import 'package:flutter/material.dart';
import 'package:flutterApp/models/camera.dart';
import 'package:flutterApp/services/reportService.dart';
import 'package:flutterApp/utils/reportConverter.dart';
import 'package:flutterApp/widgets/markerBuilders.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/models/notification.dart';
import 'dart:async';
import 'package:flutterApp/helper/appConfig.dart';
import 'package:flutterApp/widgets/placeInfor.dart';
import 'package:flutterApp/utils/scaleMap.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/predictionData.dart';

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
  final List<PredictionData> predictions;

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
    this.predictions = const [],
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
  String api = Config.api_mapbox_key;
  List<PredictionData> predictions = [];

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
    if (widget.predictions != oldWidget.predictions) {
      setState(() {
        predictions = widget.predictions;
      });
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
    final hasRoutes = widget.routePolylines.isNotEmpty;

    final currentLocationMarker = Marker(
      point: widget.currentLocation,
      width: widget.markerSize,
      height: widget.markerSize,
      child: hasRoutes
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Center(
                child: Icon(Icons.person_pin_circle, color: Colors.white),
              ),
            )
          : Icon(
              Icons.location_on,
              color: Colors.red,
              size: widget.markerSize * 0.6,
            ),
    );

    final reportMarkers = buildReportMarkers(
      notifications: notifications,
      selectedIndex: _selectedMarkerIndex,
      zoomLevel: widget.zoomLevel,
      displayImage: displayImage,
      onTap: (index) {
        setState(() {
          _selectedMarkerIndex = _selectedMarkerIndex == index ? null : index;
        });
      },
    );

    final placeMarkers = buildPlaceMarkers(
      places: widget.places,
      markerSize: widget.markerSize,
      showPlaceInfo: showPlaceInfo,
      context: context,
    );

    final cameraMarkers = buildCameraMarkers(
      cameras: widget.cameras,
      markerSize: widget.markerSize,
      showYoutubeDialog: showYoutubeDialog,
      context: context,
    );

    List<Marker> interceptorMarkers = widget.routePolylines.expand((route) {
      List<Marker> markers = [];
      for (int i = 0; i < route['coordinates'].length; i++) {
        LatLng coord = route['coordinates'][i];

        if (i % 1 == 0) {
          markers.add(Marker(
            point: coord,
            width: 16.0,
            height: 16.0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(31, 239, 217, 217),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.circle,
                color: Color.fromARGB(255, 58, 58, 58),
                size: 5,
              ),
            ),
          ));
        }
      }
      return markers;
    }).toList();

    List<LatLng> interpolatePoints(List<LatLng> points, int segmentsPerLine) {
      List<LatLng> result = [];
      for (int i = 0; i < points.length - 1; i++) {
        LatLng start = points[i];
        LatLng end = points[i + 1];
        result.add(start);
        for (int j = 1; j < segmentsPerLine; j++) {
          double lat = start.latitude +
              (end.latitude - start.latitude) * (j / segmentsPerLine);
          double lng = start.longitude +
              (end.longitude - start.longitude) * (j / segmentsPerLine);
          result.add(LatLng(lat, lng));
        }
      }
      result.add(points.last);
      return result;
    }

    List<Polyline> _buildPredictionPolylinesWithMorePadding() {
      return widget.predictions.expand((prediction) {
        final points = prediction.roadSegment.roadSegmentLine.coordinates
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();

        return [
          Polyline(
            points: points,
            color: Colors.yellow.withOpacity(0.03),
            strokeWidth: 20.0,
          ),
          Polyline(
            points: points,
            color: Colors.yellow.withOpacity(0.3),
            strokeWidth: 14.0,
          ),
          Polyline(
            points: points,
            color: Colors.yellow.withOpacity(0.5),
            strokeWidth: 10.0,
          ),
          Polyline(
            points: points,
            color: Colors.yellow.withOpacity(1.0),
            strokeWidth: 5.0,
          ),
        ];
      }).toList();
    }

    List<CircleMarker> _buildPredictionCircles() {
      return widget.predictions.expand((prediction) {
        final points = prediction.roadSegment.roadSegmentLine.coordinates
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();

        final interpolatedPoints = interpolatePoints(points, 10);

        return interpolatedPoints.map((point) {
          return CircleMarker(
            point: point,
            radius: 8,
            color: Colors.orange.withOpacity(0.1),
            useRadiusInMeter: false,
          );
        });
      }).toList();
    }

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
        Stack(
          children: [
            if (widget.routePolylines.isNotEmpty)
              PolylineLayer(
                polylines: widget.routePolylines
                    .map((route) {
                      final coordinates = route['coordinates'] as List<LatLng>;
                      final recommended = route['recommended'] as bool;

                      List<Polyline> polylineList = [];

                      if (recommended && !firstRecommend) {
                        firstRecommend = true;

                        polylineList.add(
                          Polyline(
                            points: coordinates,
                            strokeWidth: 7.0,
                            color: Colors.blueAccent,
                          ),
                        );
                        polylineList.add(
                          Polyline(
                            points: coordinates,
                            strokeWidth: 6.0,
                            color: Colors.blue,
                          ),
                        );
                      } else {
                        // Tuyến khác
                        polylineList.add(
                          Polyline(
                            points: coordinates,
                            strokeWidth: recommended ? 5.0 : 4.0,
                            color: recommended
                                ? const Color.fromARGB(255, 156, 194, 239)
                                : const Color.fromARGB(
                                    255, 185, 221, 255), // xanh nhạt
                          ),
                        );
                      }

                      return polylineList;
                    })
                    .expand((polyline) => polyline)
                    .toList(),
              ),

            // Layer hiển thị các điểm tắc nghẽn (dùng marker tròn đỏ)
            MarkerLayer(
              markers: widget.routePolylines.expand((route) {
                final reports = route['reports'] as List<Map<String, dynamic>>;
                return reports.map((report) {
                  final LatLng reportPoint =
                      LatLng(report['latitude'], report['longitude']);

                  return Marker(
                    point: reportPoint,
                    width: 20.0,
                    height: 20.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 253, 94, 83),
                        border: Border.all(
                          color: const Color.fromARGB(255, 248, 165, 165),
                          width: 4.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.circle,
                        color: Color.fromARGB(255, 227, 6, 6),
                        size: 12,
                      ),
                    ),
                  );
                }).toList();
              }).toList(),
            ),
          ],
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
        PolylineLayer(
          polylines: [
            ..._buildPredictionPolylinesWithMorePadding(),
          ],
        ),
        CircleLayer(
          circles: _buildPredictionCircles(),
        ),
        MarkerLayer(
          key: ValueKey(_selectedMarkerIndex),
          markers: [
            currentLocationMarker,
            ...widget.additionalMarkers,
            ...placeMarkers,
            ...reportMarkers,
            ...cameraMarkers,
            ...interceptorMarkers,
          ],
        ),
      ],
    );
  }
}
