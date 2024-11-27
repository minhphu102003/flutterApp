import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/helper/location.dart';
import 'package:flutterApp/services/locationService.dart';
import 'package:flutterApp/Screens/placeDetail.dart';

class MapDisplay extends StatefulWidget  {
  final LatLng currentLocation;
  final List<List<LatLng>> routePolylines;
  final MapController mapController;
  final bool mapReady;
  final void Function() onMapReady;
  final double markerSize;
  final void Function(TapPosition, LatLng) onMapTap;
  final List<Marker> additionalMarkers; // Danh sách marker tùy chỉnh
  final List<Place> places; // Thêm tham số places
  final Function(LatLng start, LatLng destination) onDirectionPressed;

  MapDisplay({
    Key? key,
    required this.currentLocation,
    required this.routePolylines,
    required this.mapController,
    required this.mapReady,
    required this.onMapReady,
    required this.onMapTap,
    this.additionalMarkers = const [], // Khởi tạo danh sách rỗng
    this.markerSize = 30.0,
    this.places = const [],
    required this.onDirectionPressed, // Khởi tạo danh sách places
  }) : super(key: key);

  @override
  _MapDisplayState createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay>  {
  double _imageSize = 40.0;
  int? _selectedMarkerIndex;

  final List<Map<String, dynamic>> fakeReports = [
    {
      'latitude': 16.07244931885037,
      'longitude': 108.2084066511162,
      'img': 'https://hoanghamobile.com/tin-tuc/wp-content/uploads/2024/07/anh-obito-2.jpg', 
    },
    {
      'latitude': 16.07255000000000,
      'longitude': 108.20850000000000,
      'img': 'https://hoanghamobile.com/tin-tuc/wp-content/uploads/2024/07/anh-obito-2.jpg',
    },
  ];
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
                        // Navigator.pop(context);
                        widget.onDirectionPressed(widget.currentLocation , destination);
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
    List<Marker> reportMarkers = List.generate(fakeReports.length, (index) {
      final report = fakeReports[index];
      return Marker(
        point: LatLng(report['latitude'], report['longitude']),
        width: _imageSize, // Kích thước của marker
        height: _imageSize, // Kích thước của marker
        child: GestureDetector(
          onTap: () {
            setState(() {
              print(_selectedMarkerIndex);
              if (_selectedMarkerIndex == index) {
                _selectedMarkerIndex = null; // Nếu đã chọn thì bỏ chọn
              } else {
                _selectedMarkerIndex = index;
              }
            });
          },
          child: Container(
            width: _selectedMarkerIndex == index ? 80.0 : _imageSize, // Chỉ thay đổi kích thước của marker được chọn
            height: _selectedMarkerIndex == index ? 80.0 : _imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.red, width: 3.0),
              image: DecorationImage(
                image: NetworkImage(report['img']),
                fit: BoxFit.cover,
              ),
            ),
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
              "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$api",
        ),
        // if (routePolyline.isNotEmpty)
        //   PolylineLayer(
        //     polylines: [
        //       Polyline(
        //         points: routePolyline,
        //         strokeWidth: 4.0,
        //         color: Colors.blue,
        //       )
        //     ],
        //   ),
        if (widget.routePolylines.isNotEmpty)
        PolylineLayer(
          polylines: [
            for (int i = 0; i < widget.routePolylines.length; i++)
              Polyline(
                points: widget.routePolylines[i],
                strokeWidth: 4.0,
                color: i == 0 ? Colors.blue : const Color.fromARGB(255, 182, 182, 182).withOpacity(0.7),
              ),
          ],
        ),
        MarkerLayer(
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
            // Marker tùy chỉnh từ danh sách
            ...widget.additionalMarkers,
            // Marker cho các địa điểm
            ...placeMarkers,

            ...reportMarkers, 
          ],
        ),
      ],
    );
  }
}
