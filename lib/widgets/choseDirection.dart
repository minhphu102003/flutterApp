import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ChoseDirection extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(bool isStart) onMapIconPressed;
  final void Function(bool isStart, String text) onTextChanged;
  final LatLng? startPosition;
  final LatLng? endPosition;
  final bool isStartPosition;

  const ChoseDirection({
    super.key,
    required this.onClose,
    required this.onTextChanged,
    required this.onMapIconPressed,
    this.startPosition,
    this.endPosition,
    required this.isStartPosition,
  });

  @override
  State<ChoseDirection> createState() => _ChoseDirectionState();
}

class _ChoseDirectionState extends State<ChoseDirection> {
  late TextEditingController startController;
  late TextEditingController endController;

  @override
  void initState() {
    super.initState();
    startController = TextEditingController(
      text: widget.startPosition != null
          ? "${widget.startPosition!.latitude}, ${widget.startPosition!.longitude}"
          : "",
    );
    endController = TextEditingController(
      text: widget.endPosition != null
          ? "${widget.endPosition!.latitude}, ${widget.endPosition!.longitude}"
          : "",
    );
    startController.addListener(() {
      widget.onTextChanged(true, startController.text);
    });

    endController.addListener(() {
      widget.onTextChanged(false, endController.text);
    });
  }

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    widget.onClose(); // Gọi hàm từ cha khi đóng overlay
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Vị trí bắt đầu
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: startController,
                    decoration: const InputDecoration(
                      hintText: 'Vị trí xuất phát',
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.blue),
                  onPressed: () {
                    widget.onMapIconPressed(true); // Chọn vị trí bắt đầu
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Row 2: Điểm đến
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: endController,
                    decoration: const InputDecoration(
                      hintText: 'Chọn điểm đến',
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.blue),
                  onPressed: () {
                    widget.onMapIconPressed(false); // Chọn điểm đến
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Row 3: Các phương tiện
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.directions_car),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.directions_bus),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.motorcycle),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.directions_bike),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.directions_walk),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}