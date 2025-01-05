import 'package:flutter/material.dart';
import 'package:flutterApp/helper/extentisions.dart';
import 'package:flutterApp/models/dailyWeather.dart';
import 'package:flutterApp/provider/weatherProvider.dart';
import 'package:flutterApp/screens/sevenDayForecastDetailScreen.dart';
import 'package:flutterApp/theme/colors.dart';
import 'package:flutterApp/theme/textStyle.dart';
import 'package:flutterApp/widgets/customShimer.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../helper/utils.dart';

// Widget cho dự báo thời tiết trong 7 ngày
class SevenDayForecast extends StatelessWidget {
  const SevenDayForecast({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề cho dự báo thời tiết
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const PhosphorIcon(PhosphorIconsRegular.calendar), // Biểu tượng lịch
              const SizedBox(width: 4.0),
              const Text(
                '7-Day Forecast',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Consumer<Weatherprovider>( // Đọc dữ liệu từ Weatherprovider
                builder: (context, weatherProv, _) {
                  return TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      textStyle: mediumText.copyWith(fontSize: 14.0),
                      foregroundColor: primaryBlue,
                    ),
                    onPressed: weatherProv.isLoading
                        ? null // Không cho phép nhấn nếu đang tải dữ liệu
                        : () {
                            Navigator.of(context).pushNamed(
                              SevenDayForecastDetail.routeName, // Điều hướng đến màn hình chi tiết
                            );
                          },
                    child: const Text('more detail ▶'),
                  );
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          child: Consumer<Weatherprovider>(builder: (context, weatherProv, _) {
            // Hiển thị khung dữ liệu nếu đang tải
            if (weatherProv.isLoading) {
              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: 7,
                itemBuilder: (context, index) => CustomShimmer( // Hiệu ứng nhấp nháy
                  height: 82.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              );
            }
            // Hiển thị danh sách dự báo thời tiết
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(), // Không cuộn được
              itemCount: weatherProv.dailyWeather.length,
              itemBuilder: (context, index) {
                final Dailyweather weather = weatherProv.dailyWeather[index]; // Lấy dữ liệu thời tiết
                return Material(
                  borderRadius: BorderRadius.circular(12.0),
                  color: index.isEven ? backgroundWhite : Colors.white, // Đổi màu nền cho từng dòng
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () {
                      // Điều hướng đến màn hình chi tiết khi nhấn
                      Navigator.of(context).pushNamed(
                        SevenDayForecastDetail.routeName,
                        arguments: index,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Ngày trong tuần
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width / 4,
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                index == 0
                                    ? 'Today' // Hiển thị "Hôm nay" cho chỉ số 0
                                    : DateFormat('EEE').format(weather.date), // Định dạng ngày
                                style: semiboldText,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          // Thời tiết
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 36.0,
                                height: 36.0,
                                child: Image.asset(
                                  getWeatherImage(weather.weatherCategory), // Lấy hình ảnh thời tiết
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                weather.weatherCategory,
                                style: lightText,
                              ),
                            ],
                          ),
                          // Nhiệt độ tối đa và tối thiểu
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width / 5,
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                weatherProv.isCelsius
                                    ? '${weather.tempMax.toStringAsFixed(0)}°/${weather.tempMin.toStringAsFixed(0)}°' // Định dạng nhiệt độ
                                    : '${weather.tempMax.toFahrenheit().toStringAsFixed(0)}°/${weather.tempMin.toFahrenheit().toStringAsFixed(0)}°',
                                style: semiboldText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
