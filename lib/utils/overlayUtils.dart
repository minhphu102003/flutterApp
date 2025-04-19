import 'package:flutter/material.dart';
import 'package:flutterApp/widgets/choseDirection.dart';
import 'package:latlong2/latlong.dart';

class OverlayUtils {
  static OverlayEntry buildCameraOverlay({
    required BuildContext context,
    required bool isSelectingStart,
    required LatLng? startPosition,
    required LatLng? endPosition,
    required void Function() onClose,
    required void Function(bool, String) onTextChanged,
    required void Function(bool) onMapIconPressed,
    required void Function(bool isSelectingStart, bool findRoutes, int topSuggestList) onStateUpdate,
  }) {
    return OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 225,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ChoseDirection(
                onClose: onClose,
                isStartPosition: isSelectingStart,
                startPosition: startPosition,
                endPosition: endPosition,
                onTextChanged: (isStart, query) {
                  onStateUpdate(isStart, true, 170);
                  onTextChanged(isStart, query);
                },
                onMapIconPressed: (isStart) {
                  onStateUpdate(isStart, true, 0);
                  onMapIconPressed(isStart);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
