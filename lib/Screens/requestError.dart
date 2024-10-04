import 'package:flutter/material.dart';
import 'package:flutterApp/theme/colors.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:provider/provider.dart';

import '../provider/weatherProvider.dart';
import '../theme/textStyle.dart';

class RequestErrorDisplay extends StatelessWidget {
  const RequestErrorDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hình ảnh thông báo lỗi
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width,
              minWidth: 100,
              maxHeight: MediaQuery.sizeOf(context).height / 3,
            ),
            child: Image.asset('assets/images/requestError.png'),
          ),
          Center(
            child: Text(
              'Request Error', // Tiêu đề thông báo lỗi
              style: boldText.copyWith(color: primaryBlue),
            ),
          ),
          const SizedBox(height: 4.0),
          Center(
            child: Text(
              'Request error, please check your internet connection', // Nội dung thông báo
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
                child: Text('Return Home'), // Nút trở về trang chính
                onPressed: weatherProv.isLoading
                    ? null // Nếu đang tải, nút sẽ bị vô hiệu hóa
                    : () async {
                        await weatherProv.getWeatherData(context, notify: true);
                    },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SearchErrorDisplay extends StatelessWidget {
  const SearchErrorDisplay({Key? key, required this.fsc}) : super(key: key);

  final FloatingSearchBarController fsc; // Controller cho thanh tìm kiếm

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hình ảnh thông báo lỗi tìm kiếm
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width,
              minWidth: 100,
              maxHeight: MediaQuery.sizeOf(context).height / 3,
            ),
            child: Image.asset('assets/images/searchError.png'),
          ),
          Center(
            child: Text(
              'Search Error', // Tiêu đề thông báo lỗi tìm kiếm
              style: boldText.copyWith(color: primaryBlue),
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
                  shape: const StadiumBorder(),
                ),
                onPressed: weatherProv.isLoading
                    ? null // Nếu đang tải, nút sẽ bị vô hiệu hóa
                    : () async {
                        await weatherProv.getWeatherData(context, notify: true);
                    },
                child: const Text('Return Home'), // Nút trở về trang chính
              ),
            );
          }),
        ],
      ),
    );
  }
}
