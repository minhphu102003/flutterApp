import 'package:flutter/material.dart';

class FloatingReportButton extends StatefulWidget {
  final VoidCallback changeScreen;
  final VoidCallback openCamera;
  final VoidCallback poststatus;
  final VoidCallback changeHidden; // Thêm tham số

  final double bottom;
  final double left;

  const FloatingReportButton({
    Key? key,
    required this.changeScreen,
    required this.openCamera,
    required this.poststatus,
    required this.changeHidden, // Thêm tham số bắt buộc
    this.left = 10,
    this.bottom = 50,
  }) : super(key: key);

  @override
  _FloatingReportButtonState createState() => _FloatingReportButtonState();
}

class _FloatingReportButtonState extends State<FloatingReportButton> {
  bool _isHidden = true; // Trạng thái để quản lý icon của button "hidden_image"

  void toggleHidden() {
    setState(() {
      _isHidden = !_isHidden; // Đổi trạng thái khi người dùng nhấn nút
    });
    widget.changeHidden(); // Gọi hàm từ widget cha
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Button 1
        Positioned(
          bottom: widget.bottom,
          left: widget.left,
          child: FloatingActionButton(
            onPressed: widget.changeScreen,
            heroTag: "report_traffic",
            child: const Icon(Icons.camera_enhance_outlined),
          ),
        ),
        // Button 2
        Positioned(
          bottom: widget.bottom + 65, // Điều chỉnh vị trí để xếp các nút
          left: widget.left,
          child: FloatingActionButton(
            onPressed: widget.openCamera,
            heroTag: "show_direction",
            child: const Icon(Icons.directions),
          ),
        ),
        // Button 3
        Positioned(
          bottom: widget.bottom + 130, // Điều chỉnh vị trí để xếp các nút
          left: widget.left,
          child: FloatingActionButton(
            onPressed: widget.poststatus,
            heroTag: "post_status",
            child: const Icon(Icons.warning),
          ),
        ),
        // Button 4
        Positioned(
          bottom: widget.bottom + 195, // Điều chỉnh vị trí để xếp các nút
          left: widget.left,
          child: FloatingActionButton(
            onPressed: toggleHidden, // Gọi hàm đổi trạng thái và hàm cha
            heroTag: "hidden_image",
            child: Icon(
              _isHidden ? Icons.hide_image : Icons.image, // Thay đổi icon dựa trên trạng thái
            ),
          ),
        ),
      ],
    );
  }
}
