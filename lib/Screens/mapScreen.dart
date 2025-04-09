import 'package:flutter/material.dart';
import 'package:flutterApp/helper/navigation_helpers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/services/mapSerivice.dart';
import 'package:flutterApp/services/weatherSuggestionService.dart';
import 'package:flutterApp/widgets/floatActingButton.dart';
import 'package:flutterApp/widgets/buttonWeather.dart';
import 'package:flutterApp/widgets/searchBar.dart' as custom;
import 'package:flutterApp/widgets/displayMap.dart';
import 'package:flutterApp/widgets/routeInstruction.dart';
import 'package:flutterApp/widgets/suggestionList.dart';
import 'package:flutterApp/widgets/FloatButtonReport.dart';
import 'package:flutterApp/screens/reportScreen.dart';
import 'package:flutterApp/widgets/choseDirection.dart';
import 'package:flutterApp/screens/poststatus.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/services/placeService.dart';
import 'package:flutterApp/models/notification.dart';

class MapScreen extends StatefulWidget {
  final double? longitude;
  final double? latitude;
  final Function(double longitude, double latitude) onLocationChanged;

  const MapScreen(
      {super.key,
      required this.onLocationChanged,
      this.longitude,
      this.latitude});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  GlobalKey<MapScreenState> mapKey = GlobalKey<MapScreenState>();
  String apiMapboxKey = Config.api_mapbox_key;
  LatLng _currentLocation = const LatLng(37.7749, -122.4194);
  bool _locationLoaded = false;
  double _zoomLevel = 16.0;
  late MapController _mapController;
  bool _mapReady = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _suggestionsGoongMap = [];
  LatLng? _searchedLocation;
  List<Map<String, dynamic>> _routePolylines = [];
  List<List<String>> _routeInstructions = [];
  final String _travelTime = "";
  bool _showRouteInstructions = true;
  bool _isDialogShown = false;
  double _markerSize = 30;
  final weatherService = WeatherSuggestionService();
  OverlayEntry? _currentOverlayEntry;
  LatLng? _startPosition;
  LatLng? _endPosition;
  bool _isSelectingStart = true;
  bool _findRoutes = false;
  double topSuggeslist = 90;
  List<Place> places = [];
  List<TrafficNotification> notifications = [];
  GlobalKey<MapDisplayState> MapdisplayKey = GlobalKey<MapDisplayState>();
  final MapApiService _mapApiService = MapApiService();

  void addNotification(TrafficNotification notification) {
    setState(() {
      MapdisplayKey.currentState?.addNotifications(notification);
      notifications.add(notification);
    });
  }

  void _changeDisplayImage({bool? change}) {
    setState(() {
      MapdisplayKey.currentState?.changeDisplayImage(value: change);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _suggestionsGoongMap.clear();
      _routePolylines.clear();
      _showRouteInstructions = false;
      _startPosition = null;
      _endPosition = null;
      _findRoutes = false;
      _changeDisplayImage();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController = MapController();
    _initializeLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void updateLocation(double longitude, double latitude) {
    setState(() {
      _currentLocation = LatLng(latitude, longitude);
    });
    if (_mapReady) {
      _mapController.move(_currentLocation, _zoomLevel);
    }
  }

  void _changeScreen(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ReportScreen()));
  }

  void _changePost(context, double longitude, double latitude) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreatePostScreen(
                  longitude: longitude,
                  latitude: latitude,
                )));
  }

  void _toggleCameraOverlay(BuildContext context) {
    if (_currentOverlayEntry != null) {
      _closeOverlay();
    } else {
      _openCamera(context);
    }
  }

  void _closeOverlay() {
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }
  }

  void _onSelectPosition(LatLng position, bool isStartPosition) {
    setState(() {
      topSuggeslist = 90;
      if (isStartPosition) {
        _startPosition = position;
      } else {
        _endPosition = position;
      }
    });
    _toggleCameraOverlay(context);
    if (_startPosition != null && _endPosition != null) {
      _closeOverlay();
      _getRoute(_startPosition!, _endPosition!);
    }
  }

  void _adjustZoomAndMarker() {
    setState(() {
      _zoomLevel += 1; // Tăng zoom lên 1
      _markerSize = 50.0;
    });
    if (_mapReady) {
      _mapController.move(_currentLocation, _zoomLevel);
    }
  }

  void _handleCloseOverlayAndAdjustMap() {
    _closeOverlay();
    _adjustZoomAndMarker();
  }

  void _openCamera(BuildContext context) {
    OverlayState overlayState = Overlay.of(context)!;

    _currentOverlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 225,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ChoseDirection(
                onClose: _handleCloseOverlayAndAdjustMap,
                isStartPosition: _isSelectingStart,
                startPosition: _startPosition,
                endPosition: _endPosition,
                onTextChanged: (isStart, query) {
                  setState(() {
                    _isSelectingStart = isStart;
                    _findRoutes = true;
                    if (isStart) {
                      topSuggeslist = 170;
                    } else {
                      topSuggeslist = 170;
                    }
                  });
                  _onSearchChanged(query);
                },
                onMapIconPressed: (isStart) {
                  setState(() {
                    _isSelectingStart = isStart;
                    _findRoutes = true;
                    _suggestionsGoongMap.clear();
                  });
                  _toggleCameraOverlay(context);
                },
              ),
            ),
          ),
        );
      },
    );
    overlayState.insert(_currentOverlayEntry!);
  }

  void _onMapTap(TapPosition position, LatLng latLng) {
    if (_currentOverlayEntry == null && _findRoutes) {
      _onSelectPosition(latLng, _isSelectingStart);
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    if (_startPosition != null) {
      markers.add(
        Marker(
          point: _startPosition!,
          width: 30,
          height: 30,
          child: const Icon(
            Icons.location_on,
            color: Colors.green, // Marker màu xanh lá cho điểm bắt đầu
            size: 40,
          ),
        ),
      );
    }
    if (_endPosition != null) {
      markers.add(
        Marker(
          point: _endPosition!,
          width: 30,
          height: 30,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue, // Marker màu xanh dương cho điểm kết thúc
            size: 40,
          ),
        ),
      );
    }
    return markers;
  }

  Future<void> fetchPlaces() async {
    try {
      final result = await PlaceService().fetchNearestPlaces(
          longitude: _currentLocation.longitude,
          latitude: _currentLocation.latitude,
          radius: 1);
      setState(() {
        places = result.data;
      });
    } catch (e) {}
  }

  void _onMapReady() {
    setState(() {
      _mapReady = true;
      if (_currentLocation != null) {
        _mapController.move(_currentLocation, _zoomLevel);
      }
      if (!_isDialogShown) {
        _isDialogShown = true;
        weatherService.showWeatherSuggestion(
            _currentLocation.longitude, _currentLocation.latitude, context);
      }
    });
  }

  Future<void> _initializeLocation() async {
    if (widget.longitude != null && widget.latitude != null) {
      _currentLocation = LatLng(widget.latitude!, widget.longitude!);
      setState(() => _locationLoaded = true);
      widget.onLocationChanged(widget.longitude!, widget.latitude!);
    } else {
      await _getCurrentLocation();
    }
    await fetchPlaces();
  }

  Future<void> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        widget.onLocationChanged(
            _currentLocation.longitude!, _currentLocation.latitude!);
        _locationLoaded = true;
        if (_mapReady) _mapController.move(_currentLocation, _zoomLevel);
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    LatLng? location = await MapApiService.getPlaceCoordinates(query);
    topSuggeslist = 90;
    if (location != null) {
      setState(() => _searchedLocation = location);
      _mapController.move(location, _zoomLevel);
      if (_findRoutes) {
        if (_isSelectingStart) {
          _startPosition = location;
        } else {
          _endPosition = location;
        }
      } else {
        _currentLocation = location;
        _markerSize = 50.0;
      }
    }
    if (_startPosition != null && _endPosition != null) {
      _closeOverlay();
      _suggestionsGoongMap.clear();
      _getRoute(_startPosition!, _endPosition!);
    }
  }

  Future<void> _getRoute(LatLng start, LatLng destination) async {
    try {
      final result =
          await _mapApiService.getRoutesWithInstructions(start, destination);
      final routesWithInstructions = result['routesWithInstructions'] as List;

      setState(() {
        _routePolylines = routesWithInstructions.map((route) {
          final coordinates = route['coordinates']
              as List<LatLng>; // No need to map to LatLng again
          final recommended = route['recommended'] as bool;
          final report = route['report'] as List<Map<String, dynamic>>;
          return {
            'coordinates': coordinates,
            'recommended': recommended,
            'report': report,
          };
        }).toList();

        if (_routePolylines != null) {
          _changeDisplayImage(change: true);
        }

        _routeInstructions = routesWithInstructions
            .map((route) => route['instructions'] as List<String>)
            .toList();
        _showRouteInstructions = true;
      });
    } catch (e) {}
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      List<Map<String, String>> suggestions =
          await MapApiService.getSuggestionsVerGoongMap(
              query, _currentLocation.latitude, _currentLocation.longitude);
      setState(() => _suggestionsGoongMap = suggestions);
    } else {
      setState(() => _suggestionsGoongMap.clear());
    }
  }

  Future<void> _selectSuggestion(String suggestion) async {
    topSuggeslist = 90;
    FocusScope.of(context).unfocus();
    final selectedItem = _suggestionsGoongMap.firstWhere(
      (item) => item['description'] == suggestion,
      orElse: () => {},
    );
    final placeId = selectedItem['place_id'];
    _suggestionsGoongMap.clear();
    if (placeId != null) {
      _searchController.text = suggestion;
      _suggestionsGoongMap.clear();
      await _searchLocation(placeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (_locationLoaded)
            MapDisplay(
              key: MapdisplayKey,
              currentLocation: _currentLocation,
              routePolylines: _routePolylines,
              mapController: _mapController,
              mapReady: _mapReady,
              onMapReady: _onMapReady,
              onMapTap: _onMapTap, // Gọi khi nhấn vào bản đồ
              markerSize: _markerSize,
              additionalMarkers: _buildMarkers(),
              places: places,
              onDirectionPressed: (LatLng start, LatLng destination) {
                Navigator.pop(context); // Đóng modal
                _getRoute(start, destination); // Gọi hàm ở widget cha
              },
              notifications: notifications,
            ),
          custom.SearchBar(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onSearchSubmitted: () => _searchLocation(_searchController.text),
            onClear: _clearSearch,
            top: 40,
            left: 10,
            right: 10,
          ),
          if (_showRouteInstructions && _routeInstructions.isNotEmpty)
            RouteInstructions(
              routeInstructions: _routeInstructions[0],
              travelTime: _travelTime,
              bottomPosition: 50, // Định vị trí tính từ đáy màn hình
            ),
          WeatherIcon(
            onPressed: () => onWeatherButtonPressed(context),
            top: 160,
            left: 20,
          ),
          FloatingActionButtons(
            onZoomIn: () {
              setState(() {
                _zoomLevel++;
                _mapController.move(_currentLocation, _zoomLevel);
              });
            },
            onZoomOut: () {
              setState(() {
                _zoomLevel--;
                _mapController.move(_currentLocation, _zoomLevel);
              });
            },
            onCurrentLocation: _getCurrentLocation,
            bottom: 50,
            right: 10,
          ),
          FloatingReportButton(
            changeScreen: () => _changeScreen(context),
            openCamera: () => _toggleCameraOverlay(context),
            poststatus: () => _changePost(
                context, _currentLocation.longitude, _currentLocation.latitude),
            changeHidden: _changeDisplayImage,
          ),
          if (_suggestionsGoongMap.isNotEmpty)
            SuggestionsList(
              // suggestions: _suggestions,
              suggestions: _suggestionsGoongMap
                  .map((item) => item['description'] ?? '')
                  .toList(),
              onSuggestionSelected: _selectSuggestion,
              top: topSuggeslist,
            ),
        ],
      ),
    );
  }
}
