import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/services/locationService.dart';
import 'package:flutterApp/constants/transportMode.dart';
import 'package:flutterApp/widgets/transportSelector.dart';
import 'package:flutterApp/widgets/locationInputField.dart';
import 'package:flutter/cupertino.dart';

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
  TransportMode _selectedMode = TransportMode.car;

  void _selectTransportMode(TransportMode mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  Future<void> _loadAddress(LatLng position, {required bool isStart}) async {
    final address = await LocationService.fetchAddress(
        position.latitude, position.longitude);
    setState(() {
      if (isStart) {
        startController.text = address;
      } else {
        endController.text = address;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startController = TextEditingController();
    endController = TextEditingController();

    if (widget.startPosition != null) {
      _loadAddress(
        widget.startPosition!,
        isStart: true,
      );
    }

    if (widget.endPosition != null) {
      _loadAddress(
        widget.endPosition!,
        isStart: false,
      );
    }

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
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransportSelector(
              selectedMode: _selectedMode,
              onModeSelected: _selectTransportMode,
            ),
            const SizedBox(height: 5),
            LocationInputField(
              controller: startController,
              hintText: 'Starting position',
              icon: CupertinoIcons.circle, // mảnh hơn Icons.circle
              onMapTap: () => widget.onMapIconPressed(true),
            ),
            const SizedBox(height: 20),
            LocationInputField(
              controller: endController,
              hintText: 'Select destination',
              icon: CupertinoIcons.location, // mảnh hơn Icons.location_on
              onMapTap: () => widget.onMapIconPressed(false),
            ),
          ],
        ),
      ),
    );
  }
}
