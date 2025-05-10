import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecentVideoShimmerCard extends StatelessWidget {
  const RecentVideoShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Positioned(
              top: 10,
              left: 10,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
