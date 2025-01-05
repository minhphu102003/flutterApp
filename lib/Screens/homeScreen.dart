import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutterApp/screens/locationError.dart';

import '../provider/weatherProvider.dart';
import '../theme/colors.dart';
import '../theme/textStyle.dart';
import '../widgets/WeatherInfoHeader.dart';
import '../widgets/sevenDayForecast.dart';
import '../widgets/mainWeatherDetail.dart';
import '../widgets/mainWeatherInfo.dart';
import '../widgets/twentyFourHourForecast.dart';
import 'requestError.dart';

// Lớp HomeScreen là màn hình chính của ứng dụng thời tiết
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  FloatingSearchBarController fsc = FloatingSearchBarController(); // Controller cho thanh tìm kiếm

  @override
  void initState() {
    super.initState();
    requestWeather(); // Gọi hàm yêu cầu dữ liệu thời tiết khi khởi tạo
  }

  // Yêu cầu dữ liệu thời tiết từ Weatherprovider
  Future<void> requestWeather() async {
    await Provider.of<Weatherprovider>(context, listen: false)
        .getWeatherData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Weatherprovider>(
        builder: (context, weatherProv, _) {
          // Kiểm tra trạng thái và hiển thị lỗi nếu cần
          if (!weatherProv.isLoading && !weatherProv.isLocationSeviceEnable) {
            return const LocationServiceErrorDisplay(); // Hiển thị lỗi nếu dịch vụ vị trí bị tắt
          }
          if (!weatherProv.isLoading &&
              weatherProv.locationPermission != LocationPermission.always &&
              weatherProv.locationPermission != LocationPermission.whileInUse) {
            return const LocationPermissionErrrorDisplay(); // Hiển thị lỗi nếu không có quyền truy cập vị trí
          }

          if (weatherProv.isRequestError) return const RequestErrorDisplay(); // Hiển thị lỗi yêu cầu nếu có

          if (weatherProv.isSearchError) return SearchErrorDisplay(fsc: fsc); // Hiển thị lỗi tìm kiếm nếu có

          return Stack(
            children: [
              // Giao diện chính hiển thị thông tin thời tiết
              ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(12.0).copyWith(
                  top: kToolbarHeight +
                      MediaQuery.viewPaddingOf(context).top +
                      24.0,
                ),
                children: [
                  const WeatherInfoHeader(), // Header thông tin thời tiết
                  const SizedBox(height: 16.0),
                  MainWeatherInfor(), // Thông tin thời tiết chính
                  const SizedBox(height: 16.0),
                  MainWeatherDetail(), // Chi tiết thời tiết
                  const SizedBox(height: 24.0),
                  const TwentyFourHourForecast(), // Dự báo thời tiết 24 giờ
                  const SizedBox(height: 18.0),
                  const SevenDayForecast(), // Dự báo thời tiết 7 ngày
                ],
              ),
              // Thanh tìm kiếm
              CustomSearchBar(fsc: fsc),
            ],
          );
        },
      ),
    );
  }
}

// Lớp CustomSearchBar để tạo thanh tìm kiếm
class CustomSearchBar extends StatefulWidget {
  final FloatingSearchBarController fsc; // Controller cho thanh tìm kiếm

  const CustomSearchBar({
    super.key,
    required this.fsc,
  });

  @override
  State<CustomSearchBar> createState() {
    return _CustomSearchBarState();
  }
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  // Danh sách gợi ý thành phố cho người dùng
  final List<String> _citiesSuggestion = [
    'New York',
    'Tokyo',
    'Dubai',
    'London',
    'Singapore',
    'Sydney',
    'Wellington'
  ];

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      controller: widget.fsc,
      hint: 'Search...', // Gợi ý tìm kiếm
      clearQueryOnClose: false,
      scrollPadding: const EdgeInsets.only(top: 16.0, bottom: 56.0),
      transitionDuration: const Duration(milliseconds: 400),
      borderRadius: BorderRadius.circular(16.0),
      transitionCurve: Curves.easeInOut,
      accentColor: primaryBlue, // Màu sắc chủ đạo của thanh tìm kiếm
      hintStyle: regularText,
      queryStyle: regularText,
      physics: const BouncingScrollPhysics(),
      elevation: 2.0,
      debounceDelay: const Duration(milliseconds: 500), // Thời gian trễ trước khi tìm kiếm
      onQueryChanged: (query) {},
      onSubmitted: (query) async {
        widget.fsc.close(); // Đóng thanh tìm kiếm khi tìm kiếm xong
        await Provider.of<Weatherprovider>(context, listen: false)
            .searchWeather(query); // Tìm kiếm thời tiết theo tên thành phố
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        const FloatingSearchBarAction(
          showIfOpened: false,
          child: PhosphorIcon(
            PhosphorIconsBold.magnifyingGlass, // Biểu tượng tìm kiếm
            color: primaryBlue,
          ),
        ),
        FloatingSearchBarAction.icon(
          showIfClosed: false,
          showIfOpened: true,
          icon: const PhosphorIcon(
            PhosphorIconsBold.x, // Biểu tượng xóa tìm kiếm
            color: primaryBlue,
          ),
          onTap: () {
            if (widget.fsc.query.isEmpty) {
              widget.fsc.close(); // Đóng thanh tìm kiếm nếu không có truy vấn
            } else {
              widget.fsc.clear(); // Xóa truy vấn nếu có
            }
          },
        )
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _citiesSuggestion.length,
              itemBuilder: (context, index) {
                String data = _citiesSuggestion[index];
                return InkWell(
                  onTap: () async {
                    widget.fsc.query = data; // Cập nhật truy vấn thành phố được chọn
                    widget.fsc.close(); // Đóng thanh tìm kiếm
                    await Provider.of<Weatherprovider>(context, listen: false)
                        .searchWeather(data); // Tìm kiếm thời tiết theo thành phố
                  },
                  child: Container(
                    padding: const EdgeInsets.all(22.0),
                    child: Row(
                      children: [
                        const PhosphorIcon(PhosphorIconsFill.mapPin), // Biểu tượng vị trí
                        const SizedBox(width: 22.0),
                        Text(data, style: mediumText,) // Tên thành phố
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 1.0,
                height: 0.0,
              ),
            ),
          ),
        );
      },
    );
  }
}
