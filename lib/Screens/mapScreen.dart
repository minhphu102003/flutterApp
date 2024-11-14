import 'package:flutter/material.dart';
import 'package:flutterApp/helper/navigation_helpers.dart'; 
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/services/mapSerivice.dart';

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
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default location
  bool _locationLoaded = false;
  double _zoomLevel = 16.0;
  late MapController _mapController;
  bool _mapReady = false;
  TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  LatLng? _searchedLocation;
  List<LatLng> _routePolyline = [];
  List<String> _routeInstructions = [];

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
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
    List<LatLng> polylinePoints = await MapApiService.getRoute(start, destination);
    List<String> instructions = await MapApiService.getRouteInstructions(start, destination);
    setState(() {
      _routePolyline = polylinePoints;
      _routeInstructions = instructions;
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
      body: Stack(
        children: [
          _locationLoaded ? _buildMap() : const Center(child: CircularProgressIndicator()),
          _buildSearchBar(),
          if (_routeInstructions.isNotEmpty) _buildRouteInstructions(),
          if (_suggestions.isNotEmpty) _buildSuggestionsList(),
          _buildWeatherIcon(),
          _buildFloatingButtons(),
        ],
      ),
    );
  }

  // Build Map Widget
  Widget _buildMap() {
    return FlutterMap(
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
          urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$apiMapboxKey",
        ),
        if (_routePolyline.isNotEmpty)
          PolylineLayer(
            polylines: [Polyline(points: _routePolyline, strokeWidth: 4.0, color: Colors.blue)],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: _currentLocation,
              width: 30.0,
              height: 30.0,
              child: Icon(Icons.location_on, color: Colors.red),
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
    );
  }

  // Build Search Bar
  Widget _buildSearchBar() {
    return Positioned(
      top: 40,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search for a location...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _searchLocation(_searchController.text);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
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
    );
  }

  // Build Route Instructions Display
  Widget _buildRouteInstructions() {
    return Positioned(
      bottom: 100,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detailed Directions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ..._routeInstructions.map((instruction) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(instruction),
                )),
          ],
        ),
      ),
    );
  }

  // Build Suggestions List
  Widget _buildSuggestionsList() {
    return Positioned(
      top: 100,
      left: 10,
      right: 10,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
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
      ),
    );
  }

  // Build Weather Icon
  Widget _buildWeatherIcon() {
    return Positioned(
      top: 160,
      left: 20,
      child: _suggestions.isEmpty
          ? Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.cloudy_snowing, size: 30, color: Colors.white),
                onPressed: () => onWeatherButtonPressed(context),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // Build Floating Action Buttons (Zoom & Current Location)
  Widget _buildFloatingButtons() {
    return Positioned(
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
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: () {
              setState(() {
                _zoomLevel--;
                _mapController.move(_currentLocation, _zoomLevel);
              });
            },
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "current_location",
            onPressed: () => _getCurrentLocation(),
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
