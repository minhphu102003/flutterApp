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
      currentLocation,
      LatLng(place.latitude, place.longitude),
    );
    LatLng destination = LatLng(place.latitude, place.longitude);
    Future<String> addressFuture =
        LocationService.fetchAddress(place.latitude, place.longitude);

    return FractionallySizedBox(
      heightFactor: 0.5,
      widthFactor: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: Image.network(
              place.img,
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              place.name,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16.0, color: Colors.grey),
                const SizedBox(width: 4.0),
                Expanded(
                  child: FutureBuilder<String>(
                    future: addressFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 20.0,
                            color: Colors.grey[300],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          'Error fetching address',
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                        );
                      } else if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      } else {
                        return const Text(
                          'No address found',
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
                        builder: (context) => PlaceDetailScreen(place: place),
                      ),
                    );
                  },
                  child: const Text('View Details'),
                ),
                IconButton(
                  onPressed: () {
                    onDirectionPressed(currentLocation, destination);
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
  }

}