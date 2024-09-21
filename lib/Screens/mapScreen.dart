import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/mapSample.dart';
import 'package:flutter_application_1/widgets/buttonWeather.dart';
import 'package:flutter_application_1/Screens/homeScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import '../widgets/searchBar.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FloatingSearchBarController fsc = FloatingSearchBarController();
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(44.34, 10.99);
  bool _isSearchBarOpened = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onWeatherButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void _toggleSearchBar(bool isOpen) {
    setState(() {
      _isSearchBarOpened = isOpen; // Update the state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MapSample(),
          SearchBarBar(
            fsc: fsc,
            onToggle: _toggleSearchBar, // Gửi callback cho SearchBarBar
          ),
          if (!_isSearchBarOpened)
            WeatherButton(onPressed: _onWeatherButtonPressed),
        ],
      ),
    );
  }
}
