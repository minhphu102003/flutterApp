import 'package:flutter/material.dart';
import 'package:flutterApp/helper/navigation_helpers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/services/mapSerivice.dart';
import 'package:flutterApp/services/weatherSuggestionService.dart';
import 'package:flutterApp/helper/appConfig.dart';
import 'package:flutterApp/widgets/floatActingButton.dart';
import 'package:flutterApp/widgets/buttonWeather.dart';
import 'package:flutterApp/widgets/searchBar.dart' as custom;
import 'package:flutterApp/widgets/displayMap.dart';
import 'package:flutterApp/widgets/routeInstruction.dart';
import 'package:flutterApp/widgets/suggestionList.dart';

class MapScreen extends StatefulWidget {
  final double? longitude;
  final double? latitude;

  const MapScreen({Key? key, this.longitude, this.latitude}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GlobalKey<MapScreenState> mapKey = GlobalKey<MapScreenState>();
  String apiMapboxKey = Config.api_mapbox_key;
  LatLng _currentLocation = const LatLng(37.7749, -122.4194);
  bool _locationLoaded = false;
  double _zoomLevel = 16.0;
  late MapController _mapController;
  bool _mapReady = false;
  TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  LatLng? _searchedLocation;
  List<LatLng> _routePolyline = [];
  List<String> _routeInstructions = [];
  String _travelTime = "";
  String _transportMode = "driving";
  bool _showRouteInstructions = true;
  String dirImg = AppConfig.dirImg;
  bool _isDialogShown = false;
  final weatherService = WeatherSuggestionService();

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _suggestions.clear();
      _showRouteInstructions = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  // This method will update the current location
  void updateLocation(double longitude, double latitude) {
    setState(() {
      _currentLocation = LatLng(latitude, longitude);
    });
    if (_mapReady) {
      _mapController.move(_currentLocation, _zoomLevel);
    }
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
    } else {
      await _getCurrentLocation();
    }
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
        _locationLoaded = true;
        if (_mapReady) _mapController.move(_currentLocation, _zoomLevel);
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    LatLng? location = await MapApiService.searchLocation(query);
    if (location != null) {
      setState(() => _searchedLocation = location);
      _mapController.move(location, _zoomLevel);
      await _getRoute(_currentLocation, location);
    }
  }

  Future<void> _getRoute(LatLng start, LatLng destination) async {
    List<LatLng> polylinePoints =
        await MapApiService.getRoute(start, destination);
    List<String> instructions =
        await MapApiService.getRouteInstructions(start, destination);
    String travelTime = await MapApiService.getTravelTime(start, destination);
    setState(() {
      _routePolyline = polylinePoints;
      _routeInstructions = instructions;
      _travelTime = travelTime;
    });
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      List<String> suggestions = await MapApiService.getSuggestions(query);
      setState(() => _suggestions = suggestions);
    } else {
      setState(() => _suggestions.clear());
    }
  }

  Future<void> _selectSuggestion(String suggestion) async {
    _searchController.text = suggestion;
    _suggestions.clear();
    await _searchLocation(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          if(_locationLoaded)
            Positioned.fill( // Đảm bảo MapDisplay chiếm toàn bộ không gian
              child: MapDisplay(
                currentLocation: _currentLocation,
                routePolyline: _routePolyline,
                mapController: _mapController,
                mapReady: _mapReady,
                onMapReady: _onMapReady,
              ),
            ),
          custom.SearchBar(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onSearchSubmitted: () => _searchLocation(_searchController.text),
            onClear: _clearSearch,
            top: 40, // Định vị theo yêu cầu
            left: 10,
            right: 10,
          ),
          if (_showRouteInstructions && _routeInstructions.isNotEmpty)
            RouteInstructions(
              routeInstructions: _routeInstructions,
              travelTime: _travelTime,
              bottomPosition: 50, // Định vị trí tính từ đáy màn hình
            ),
          WeatherIcon(
            onPressed: () => onWeatherButtonPressed(context),
            top: 160, // Định vị trí theo yêu cầu
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
            bottom: 50, // Định vị theo yêu cầu
            right: 10,
          ),
          if (_suggestions.isNotEmpty)
            SuggestionsList(
              suggestions: _suggestions,
              onSuggestionSelected: _selectSuggestion,
            ),
        ],
      ),
    );
  }
}
