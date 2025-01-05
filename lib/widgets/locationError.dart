import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/weatherProvider.dart';

class LocationError extends StatefulWidget {
  @override
  _LocationErrorState createState() => _LocationErrorState();
}

class _LocationErrorState extends State<LocationError> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiển thị icon báo lỗi vị trí.
          const Icon(
            Icons.location_off,
            color: Colors.black,
            size: 75,
          ),
          const SizedBox(height: 10,),
          // Thông báo vị trí đang bị tắt.
          const Text(
            'Your location is disabled',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 75, vertical: 10),
            child: Text(
              'Please turn on your location service and refresh the app',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Nút "Enable Location" để yêu cầu người dùng bật dịch vụ vị trí.
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              textStyle: const TextStyle(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 50),
            ),
            child: const Text('Enable Location'),
            // Khi nhấn nút, ứng dụng sẽ thử lấy dữ liệu thời tiết bằng cách gọi hàm getWeatherData.
            onPressed: () async {
              // Gọi phương thức getWeatherData từ WeatherProvider để cập nhật thông tin thời tiết.
              await Provider.of<Weatherprovider>(context, listen: false)
                  .getWeatherData(context);
            },
          )
        ],
      ),
    );
  }
}
