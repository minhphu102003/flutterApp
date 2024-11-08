import 'package:flutter/material.dart';
import 'package:flutterApp/helper/extentisions.dart';
import 'package:flutterApp/theme/textStyle.dart';
import 'package:flutterApp/widgets/customShimer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutterApp/provider/weatherProvider.dart';
import 'package:flutterApp/theme/colors.dart';

import '../helper/utils.dart';

// Widget MainWeatherDetail hiển thị thông tin thời tiết chính, 
// bao gồm nhiệt độ cảm nhận, lượng mưa, tốc độ gió, độ ẩm và độ mây.
class MainWeatherDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lấy dữ liệu từ Weatherprovider
    return Consumer<Weatherprovider>(builder: (context, weatherProv, _) {
      // Kiểm tra trạng thái loading, nếu đang tải thì hiển thị CustomShimmer
      if (weatherProv.isLoading) {
        return CustomShimmer(
          height: 132.0,
          borderRadius: BorderRadius.circular(16.0),
        );
      }
      // Khi dữ liệu đã sẵn sàng, hiển thị thông tin thời tiết
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: backgroundWhite,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Hiển thị thông tin cảm nhận nhiệt độ
                    DetailInfoTile(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.thermometerSimple,
                        color: Colors.white,
                      ),
                      title: 'Feels Like',
                      data: weatherProv.isCelsius
                        ? '${weatherProv.weather.feelsLike.toStringAsFixed(1)}°' // Nhiệt độ cảm nhận
                        : '${weatherProv.weather.feelsLike.toFahrenheit().toStringAsFixed(1)}°', // Chuyển đổi sang Fahrenheit
                    ),
                    const VerticalDivider(
                      thickness: 1.0,
                      indent: 4.0,
                      endIndent: 4.0,
                      color: backgroundBlue,
                    ),
                    // Hiển thị lượng mưa
                    DetailInfoTile(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.drop,
                        color: Colors.white,
                      ),
                      title: 'Precipitation',
                      data: '${weatherProv.dailyWeather[0].precipitation}', // Lượng mưa trong ngày
                    ),
                    const VerticalDivider(
                      thickness: 1.0,
                      indent: 4.0,
                      endIndent: 4.0,
                      color: backgroundBlue,
                    ),
                    // Hiển thị lượng mưa (Rain Volume)
                    DetailInfoTile(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.sun,
                        color: Colors.white,
                      ),
                      title: 'Rain Volume',
                      data: uviValueToString(
                        weatherProv.dailyWeather[0].rainVolume,
                      ), // Hàm chuyển đổi giá trị lượng mưa
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 1.0,
              color: backgroundBlue,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  // Hiển thị thông tin tốc độ gió
                  DetailInfoTile(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.wind,
                      color: Colors.white,
                    ),
                    title: 'Wind',
                    data: '${weatherProv.weather.windSpeed} m/s', // Tốc độ gió
                  ),
                  const VerticalDivider(
                    thickness: 1.0,
                    indent: 4.0,
                    endIndent: 4.0,
                    color: backgroundBlue,
                  ),
                  // Hiển thị độ ẩm
                  DetailInfoTile(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.dropHalfBottom,
                      color: Colors.white,
                    ),
                    title: 'Humidity',
                    data: '${weatherProv.weather.humidity}%', // Độ ẩm
                  ),
                  const VerticalDivider(
                    thickness: 1.0,
                    indent: 4.0,
                    endIndent: 4.0,
                    color: backgroundBlue,
                  ),
                  // Hiển thị độ mây
                  DetailInfoTile(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.cloud,
                      color: Colors.white,
                    ),
                    title: 'Cloudiness',
                    data: '${weatherProv.dailyWeather[0].clouds}%', // Độ mây
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}

// Widget DetailInfoTile dùng để hiển thị thông tin thời tiết chi tiết với icon
class DetailInfoTile extends StatelessWidget {
  final String title; // Tiêu đề thông tin
  final String data; // Dữ liệu thông tin
  final Widget icon; // Icon đại diện cho thông tin

  const DetailInfoTile({
    super.key,
    required this.title,
    required this.data,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiển thị icon trong vòng tròn
          CircleAvatar(backgroundColor: primaryBlue, child: icon,),
          const SizedBox(width: 8.0,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hiển thị tiêu đề
                FittedBox(child: Text(title, style: lightText,),),
                FittedBox(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 1.0),
                    child: Text(
                      data, // Hiển thị dữ liệu
                      style: mediumText,
                      maxLines: 1,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
