import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReportMarkerWidget extends StatelessWidget {
  final double zoom;
  final bool isSelected;
  final bool displayImage;
  final String imageUrl;
  final VoidCallback onTap;

  const ReportMarkerWidget({
    super.key,
    required this.zoom,
    required this.isSelected,
    required this.displayImage,
    required this.imageUrl,
    required this.onTap,
  });

  double getScaledSize(double baseSize) {
    return baseSize * (zoom / 15).clamp(0.5, 2.0);
  }

  @override
  Widget build(BuildContext context) {
    final double baseSize = isSelected ? 50.0 : 36.0;
    final double scaledSize = getScaledSize(baseSize);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: scaledSize,
        height: scaledSize,
        decoration: displayImage
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.red, width: 3.0),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
        child: displayImage
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromARGB(255, 253, 103, 73),
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 250, 113, 67)
                          .withOpacity(0.5),
                      spreadRadius: 4,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.warning,
                    color: const Color.fromARGB(255, 238, 88, 42),
                    size: scaledSize * 0.6,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
