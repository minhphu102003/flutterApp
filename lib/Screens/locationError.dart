import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterApp/theme/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../provider/weatherProvider.dart';
import '../theme/textStyle.dart';

// Lớp để hiển thị thông báo lỗi khi quyền truy cập vị trí không được cấp
class LocationPermissionErrrorDisplay extends StatelessWidget {
  const LocationPermissionErrrorDisplay({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<Weatherprovider>(builder: (context, weatherProv, _) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hiển thị hình ảnh lỗi quyền truy cập vị trí
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width,
                minWidth: 100,
                maxHeight: MediaQuery.sizeOf(context).height / 3,
              ),
              child: Image.asset('assets/images/locError.png'),
            ),
            // Thông báo lỗi về quyền truy cập vị trí
            Center(
              child: Text(
                weatherProv.locationPermission == LocationPermission.deniedForever 
                  ? 'Location permissions are permanently denied, Please enable manually from app settings and restart the app'
                  : 'Location permission not granted, please check your location permission',
                style: mediumText.copyWith(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              child: Column(
                children: [
                  // Nút yêu cầu quyền truy cập vị trí
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      textStyle: mediumText,
                      padding: const EdgeInsets.all(12.0),
                      shape: StadiumBorder(),
                    ),
                    child: weatherProv.isLoading 
                      ? const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          weatherProv.locationPermission == LocationPermission.deniedForever 
                            ? 'Open App Setting'
                            : 'Request Permission',
                        ),
                    onPressed: weatherProv.isLoading ? null : () async {
                      // Mở cài đặt ứng dụng nếu quyền bị từ chối vĩnh viễn, hoặc yêu cầu quyền nếu chưa được cấp
                      if (weatherProv.locationPermission == LocationPermission.deniedForever) {
                        await Geolocator.openAppSettings();
                      } else {
                        weatherProv.getWeatherData(context, notify: true);
                      }
                    },
                  ),
                  const SizedBox(height: 4.0),
                  // Nút để khởi động lại yêu cầu nếu quyền bị từ chối vĩnh viễn
                  if (weatherProv.locationPermission == LocationPermission.deniedForever)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: primaryBlue
                      ),
                      child: Text('Restart'),
                      onPressed: weatherProv.isLoading 
                        ? null 
                        : () => weatherProv.getWeatherData(context, notify: true),
                    )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Lớp để hiển thị thông báo lỗi khi dịch vụ vị trí bị tắt
class LocationServiceErrorDisplay extends StatefulWidget {
  const LocationServiceErrorDisplay({Key? key}) : super(key: key);
  
  @override
  State<LocationServiceErrorDisplay> createState() {
    return _LocationServiceErrorDisplayState();
  }
}

class _LocationServiceErrorDisplayState extends State<LocationServiceErrorDisplay> {
  late StreamSubscription<ServiceStatus> serviceStatusStream; // StreamSubscription để theo dõi trạng thái dịch vụ vị trí

  @override
  void initState() {
    super.initState();
    // Khởi tạo stream để theo dõi trạng thái dịch vụ vị trí
    serviceStatusStream = Geolocator.getServiceStatusStream().listen((_) {});
    serviceStatusStream.onData((ServiceStatus status) {
      // Nếu dịch vụ vị trí được bật, yêu cầu dữ liệu thời tiết
      if (status == ServiceStatus.enabled) {
        print('Enable');
        Provider.of<Weatherprovider>(context, listen: false)
            .getWeatherData(context);
      }
    });
  }

  @override
  void dispose() {
    serviceStatusStream.cancel(); // Hủy đăng ký khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hiển thị hình ảnh lỗi dịch vụ vị trí
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width,
              minWidth: 100,
              maxHeight: MediaQuery.sizeOf(context).height / 3,
            ),
            child: Image.asset('assets/images/locError.png'),
          ),
          // Thông báo lỗi về dịch vụ vị trí
          Center(
            child: Text(
              'Your device location service is disabled, please turn it on before continuing',
              style: mediumText.copyWith(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16.0),
          Consumer<Weatherprovider>(builder: (context, weatherProv, _) {
            return SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  textStyle: mediumText,
                  padding: const EdgeInsets.all(12.0),
                  shape: StadiumBorder(),
                ),
                // Nút để mở cài đặt dịch vụ vị trí
                child: Text('Turn of Service'),
                onPressed: () async {
                  await Geolocator.openLocationSettings(); // Mở cài đặt vị trí
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
