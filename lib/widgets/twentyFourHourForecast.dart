import 'package:flutter/material.dart';
import 'package:flutterApp/helper/extentisions.dart';
import 'package:flutterApp/models/hourlyWeather.dart';
import 'package:flutterApp/provider/weatherProvider.dart';
import 'package:flutterApp/theme/colors.dart';
import 'package:flutterApp/theme/textStyle.dart';
import 'package:flutterApp/widgets/customShimer.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../helper/utils.dart';

class TwentyFourHourForecast extends StatelessWidget {
  const TwentyFourHourForecast({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề cho phần dự báo 24 giờ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                const PhosphorIcon(PhosphorIconsRegular.clock), // Biểu tượng đồng hồ
                const SizedBox(width: 4.0),
                Text(
                  '24-Hour Forecast',
                  style: semiboldText.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          Consumer<Weatherprovider>(builder: (context, weatherProv, _) {
            // Hiển thị khung dữ liệu nếu đang tải
            if (weatherProv.isLoading) {
              return SizedBox(
                height: 128.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: 10,
                  separatorBuilder: (context, index) => const SizedBox(width: 12.0),
                  itemBuilder: (context, index) => const CustomShimmer(
                    height: 128.0,
                    width: 64.0,
                  ),
                ),
              );
            }
            // Hiển thị danh sách thời tiết hàng giờ
            return SizedBox(
              height: 128.0,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                scrollDirection: Axis.horizontal,
                itemCount: weatherProv.hourlyWeather.length,
                itemBuilder: (context, index) => HourlyWeatherWidget(
                  index: index,
                  data: weatherProv.hourlyWeather[index], // Dữ liệu thời tiết hàng giờ
                ),
              ),
            );
          }),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class HourlyWeatherWidget extends StatelessWidget {
  final int index;
  final HourlyWeather data;

  const HourlyWeatherWidget({
    super.key,
    required this.index,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124.0,
      child: Column(
        children: [
          // Hiển thị nhiệt độ
          Consumer<Weatherprovider>(builder: (context, weatherProv, _) {
            return Text(
              weatherProv.isCelsius
                  ? '${data.temp.toStringAsFixed(1)}°' // Nhiệt độ trong độ C
                  : '${data.temp.toFahrenheit().toStringAsFixed(1)}°', // Nhiệt độ trong độ F
              style: semiboldText,
            );
          }),
          Stack(
            children: [
              const Divider(
                thickness: 2.0,
                color: primaryBlue,
              ),
              if (index == 0) // Nếu là giờ hiện tại, hiển thị dấu chấm
                Positioned(
                  top: 2.0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 42.0,
            width: 42.0,
            child: Image.asset(
              getWeatherImage(data.weatherCategory), // Lấy hình ảnh theo loại thời tiết
              fit: BoxFit.cover,
            ),
          ),
          // Tình trạng thời tiết
          FittedBox(
            child: Text(
              data.condition?.toTitleCase() ?? '', // Định dạng tên tình trạng thời tiết
              style: regularText.copyWith(fontSize: 12.0),
            ),
          ),
          const SizedBox(height: 2.0),
          // Thời gian
          Text(
            index == 0 ? 'Now' : DateFormat('hh:mm a').format(data.date), // Hiển thị giờ hiện tại hoặc giờ cụ thể
            style: regularText,
          ),
        ],
      ),
    );
  }
}
