import 'package:flutter/material.dart';
import 'package:flutterApp/helper/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import '../models/place.dart';
import '../services/locationService.dart';
import '../screens/placeDetail.dart';

class PlaceInfoWidget extends StatelessWidget {
  final Place place;
  final LatLng currentLocation;
  final Function(LatLng start, LatLng destination) onDirectionPressed;

  const PlaceInfoWidget({
    Key? key,
    required this.place,
    required this.currentLocation,
    required this.onDirectionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distance = calculateDistance(
        currentLocation, LatLng(place.latitude, place.longitude));
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Image.network(
                  place.img,
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.25,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      'assets/images/placeholder.png',
                      width: screenWidth,
                      height: screenHeight * 0.25,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name,
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16.0, color: Colors.grey),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: FutureBuilder<String>(
                            future: LocationService.fetchAddress(
                                place.latitude, place.longitude),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                      height: 20.0, color: Colors.grey[300]),
                                );
                              } else if (snapshot.hasError) {
                                return const Text('Error fetching address',
                                    style: TextStyle(color: Colors.grey));
                              } else if (snapshot.hasData) {
                                return Text(snapshot.data!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1);
                              } else {
                                return const Text('No address found',
                                    style: TextStyle(color: Colors.grey));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Type: ${place.type}',
                            style: const TextStyle(fontSize: 16.0)),
                        Text('Distance: ${distance.toStringAsFixed(2)} km',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        PlaceDetailScreen(place: place)));
                          },
                          child: const Text('View Details'),
                        ),
                        IconButton(
                          onPressed: () => onDirectionPressed(currentLocation,
                              LatLng(place.latitude, place.longitude)),
                          icon: const Icon(Icons.directions),
                          color: Colors.blue,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
