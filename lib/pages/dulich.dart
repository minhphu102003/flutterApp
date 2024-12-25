import 'package:flutter/material.dart';
import 'package:flutterApp/services/placeService.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/Screens/placeDetail.dart';
import 'package:geolocator/geolocator.dart';

class Dulich extends StatefulWidget {
  const Dulich({super.key});

  @override
  State<Dulich> createState() => _DulichState();
}

class _DulichState extends State<Dulich> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Coffee', 'icon': Icons.coffee, 'value': 'Coffee'},
    {'name': 'Hotel', 'icon': Icons.hotel, 'value': 'Hotel'},
    {'name': 'Restaurant', 'icon': Icons.restaurant, 'value': 'Restaurant'},
    {'name': 'Museum', 'icon': Icons.museum, 'value': 'Museum'},
    {
      'name': 'Tourist destination',
      'icon': Icons.tour_outlined,
      'value': 'Tourist destination'
    },
  ];
  bool isSearching = false;
  List<Place> places = [];
  List<Place> topPlaces = [];
  List<Place> placeCurrent = [];
  final List<String> locations = ['DA NANG', 'HA NOI', 'HO CHI MINH'];
  late double userLatitude;
  late double userLongitude;

  // Biến lưu vị trí hiện tại được chọn
  String selectedLocation = 'DA NANG';

  final ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  _initializeLocationAndFetchData(); // Lấy vị trí và gọi các API
}

Future<void> _initializeLocationAndFetchData() async {
  try {
    // Vị trí mặc định
    double latitude = 16.0717883;
    double longitude = 106.2118483;

    // Kiểm tra quyền và lấy vị trí hiện tại nếu được cấp
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;
    }

    // Lưu vị trí trong trạng thái
    setState(() {
      userLatitude = latitude;
      userLongitude = longitude;
    });
    print(userLatitude);
    print(userLongitude);

    // Gọi các hàm API
    await fetchPlaces(latitude, longitude);
    await fetchTopPlaces(latitude, longitude);
  } catch (e) {
    print('Error initializing location: $e');
  }
}
Future<void> fetchPlaces(double latitude, double longitude) async {
  try {
    final result = await PlaceService().fetchNearestPlaces(
      latitude: latitude,
      longitude: longitude,
    );
    setState(() {
      places = result.data;
    });
  } catch (e) {
    print('Error fetching places: $e');
  }
}

Future<void> fetchTopPlaces(double latitude, double longitude) async {
  try {
    final result = await PlaceService().fetchNearestPlaces(
      latitude: latitude,
      longitude: longitude,
      maxStar: 5,
    );
    setState(() {
      topPlaces = result.data;
    });
  } catch (e) {
    print('Error fetching top places: $e');
  }
}

Future<void> fetchPlaceByCategory(String type) async {
  setState(() {
    isSearching = true; // Đánh dấu là đang tìm kiếm
  });
  try {
    final result = await PlaceService().fetchNearestPlaces(
      type: type,
      latitude: userLatitude,
      longitude: userLongitude,
    );
    setState(() {
      placeCurrent = result.data;
    });
    if (placeCurrent.isNotEmpty) {
      _scrollController.animateTo(
        200.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  } catch (e) {
    print('Error fetching places by category: $e');
  }
}

  Future<void> searchPlaces(String query) async {
    setState(() {
      isSearching = true; // Đánh dấu là đang tìm kiếm
    });
    try {
      final result = await PlaceService()
          .searchPlaces(name: query); // API mới cho tìm kiếm
      setState(() {
        placeCurrent = result.data; // Lưu kết quả tìm kiếm vào placeCurrent
      });
      if (placeCurrent.isNotEmpty) {
        _scrollController.animateTo(
          200.0, // Đặt giá trị này tùy thuộc vào vị trí của phần tử chứa kết quả
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      print('Error searching places: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Center(
          child: Column(
            children: [
              const Text(
                'Location',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.redAccent, size: 16),
                    DropdownButton<String>(
                      value: selectedLocation, // Giá trị được chọn
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      underline:
                          Container(), // Xóa gạch chân mặc định của dropdown
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedLocation = newValue!;
                        });
                      },
                      items: locations
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (query) {
                          searchPlaces(
                              query); // Gọi hàm tìm kiếm khi người dùng nhấn Enter
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Categories
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Categories list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return categoryCard(
                      category['name'],
                      category['icon'],
                      () {
                        fetchPlaceByCategory(category['value']);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Top Trips section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Trips',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Top Trips list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: topPlaces.map((place) {
                    return tripCard(
                      place,
                      place.name, // Tên địa điểm
                      'Đà Nẵng', // Đặt cố định thành phố (nếu cần)
                      place.img, // Đường dẫn ảnh từ API
                      40, // Giá trị mặc định nếu không có giá
                      place.star, // Điểm đánh giá
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),
              // Group Trips section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Near Places',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Group Trips card in a row (horizontal scrolling)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: places.map((place) {
                    return tripCard(
                      place,
                      place.name, // Tên địa điểm
                      'Đà Nẵng', // Đặt cố định thành phố (nếu cần)
                      place.img, // Đường dẫn ảnh từ API
                      40, // Giá trị mặc định nếu không có giá
                      place.star, // Điểm đánh giá
                    );
                  }).toList(),
                ),
              ),
              isSearching
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Search Result',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'See All',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(height: 20),
              // Show search results or "Not Found"
              isSearching
                  ? placeCurrent.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: placeCurrent.map((place) {
                              return tripCard(
                                place,
                                place.name,
                                'Đà Nẵng',
                                place.img,
                                40,
                                place.star,
                              );
                            }).toList(),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Not Found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  // Trip Card Widget
  Widget tripCard(Place place, String title, String location, String imagePath,
      double price, double rating) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(place: place),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imagePath,
                height: 120,
                width: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    height: 120,
                    width: 180,
                    child: const Icon(Icons.broken_image,
                        size: 50, color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 120,
                    width: 180,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow:
                  TextOverflow.ellipsis, // Thêm thuộc tính này để cắt ngắn
              maxLines: 1, // Giới hạn chỉ hiển thị 1 dòng
            ),
            Text(location, style: const TextStyle(color: Colors.grey)),
            Row(
              children: [
                Text('\$$price/visit',
                    style: const TextStyle(color: Colors.green)),
                const Spacer(),
                const Icon(Icons.star, color: Colors.orange, size: 16),
                Text(rating.toString(), style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
