import 'package:flutter/material.dart';
import 'package:flutterApp/helper/extentisions.dart';
import 'package:flutterApp/helper/utils.dart';
import 'package:flutterApp/provider/weatherProvider.dart';
import 'package:flutterApp/theme/textStyle.dart';
import 'package:provider/provider.dart';

import 'customShimer.dart';

// Widget chính để hiển thị thông tin thời tiết
class MainWeatherInfor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để theo dõi và nhận dữ liệu từ Weatherprovider
    return Consumer<Weatherprovider>(builder: (context, weatherProv, _) {
      // Kiểm tra xem dữ liệu có đang được tải không
      if (weatherProv.isLoading) {
        // Nếu đang tải, hiển thị hiệu ứng shimmer cho hai ô thông tin
        return const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CustomShimmer(
                height: 148.0,
                width: 148.0,
              ),
            ),
            SizedBox(
              width: 16.0,
            ),
            CustomShimmer(
              height: 148.0,
              width: 148.0,
            )
          ],
        );
      }
      // Khi dữ liệu đã sẵn sàng, hiển thị thông tin thời tiết
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hiển thị nhiệt độ
                  SizedBox(
                    height: 100.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            weatherProv.isCelsius
                                ? weatherProv.weather.temp
                                    .toStringAsFixed(1) // Nhiệt độ theo Celsius
                                : weatherProv.weather.temp
                                    .toFahrenheit()
                                    .toStringAsFixed(
                                        1), // Chuyển đổi sang Fahrenheit nếu cần
                            style: boldText.copyWith(fontSize: 50),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            weatherProv
                                .measurementUnit, // Đơn vị đo (Celsius hoặc Fahrenheit)
                            style: mediumText.copyWith(fontSize: 26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Hiển thị mô tả thời tiết
                  Text(
                    weatherProv.weather.description
                        .toTitleCase(), // Mô tả thời tiết với chữ hoa
                    style: lightText.copyWith(fontSize: 16),
                  )
                ],
              ),
            ),
            // Hiển thị hình ảnh thời tiết
            SizedBox(
              height: 148.0,
              width: 148.0,
              child: Image.asset(
                getWeatherImage(weatherProv.weather
                    .weatherCategory), // Lấy hình ảnh tương ứng với thể loại thời tiết
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      );
    });
  }
}
