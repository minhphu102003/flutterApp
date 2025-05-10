import 'package:flutter/material.dart';
import 'package:flutterApp/widgets/recentVideoShimmerCard.dart';

class ShimmerRecentVideoList extends StatelessWidget {
  const ShimmerRecentVideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => const RecentVideoShimmerCard(),
      ),
    );
  }
}
