import 'package:flutter/material.dart';

class CustomDialogWeather extends StatefulWidget {
  final String title;
  final String message;
  final IconData typeIcon;
  final Color color;
  final List<String> imagePaths; // List of images
  final double temperature;
  final VoidCallback onDialogClose;

  const CustomDialogWeather({
    super.key,
    required this.title,
    required this.message,
    required this.typeIcon,
    required this.color,
    required this.imagePaths,
    required this.temperature,
    required this.onDialogClose,
  });

  @override
  _CustomDialogWeatherState createState() => _CustomDialogWeatherState();
}

class _CustomDialogWeatherState extends State<CustomDialogWeather> {
  late Color buttonColor;
  late PageController _pageController;
  int _currentPage = 0; // Theo dõi trang hiện tại

  @override
  void initState() {
    super.initState();
    buttonColor = widget.color;
    _pageController = PageController(); // Khởi tạo PageController
  }

  @override
  void dispose() {
    _pageController.dispose(); // Hủy PageController khi không sử dụng
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.typeIcon, color: widget.color),
          const SizedBox(width: 8),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20, // Điều chỉnh cỡ chữ nhỏ hơn
              fontWeight: FontWeight.bold, // Tuỳ chọn nếu bạn muốn chữ đậm
              color: Colors.black, // Màu sắc của chữ
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150.0, // Fixed height for the PageView
            width: 150.0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index; // Cập nhật trang hiện tại
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  widget.imagePaths[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imagePaths.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8.0,
                width: _currentPage == index ? 16.0 : 8.0,
                decoration: BoxDecoration(
                  color: _currentPage == index ? widget.color : Colors.grey,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.message),
          const SizedBox(height: 8),
          Text(
            "Current temperature: ${widget.temperature.toStringAsFixed(1)}°C",
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              buttonColor = Colors.grey;
            });
            Navigator.of(context).pop();
            widget.onDialogClose();
          },
          style: TextButton.styleFrom(foregroundColor: buttonColor),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
