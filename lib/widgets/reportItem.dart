import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/report.dart';
import 'package:flutterApp/utils/time.dart';
import '../widgets/reportDropdown.dart';
import 'package:flutterApp/services/reviewReportService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportItem extends StatelessWidget {
  final Report report;

  const ReportItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final DateTime adjustedTimestamp =
        report.timestamp.add(const Duration(hours: 7));
    final String formattedTime =
        DateFormat('HH:mm dd/MM/yyyy').format(adjustedTimestamp);
    final String reportId = report.reportId;
    final ReportReviewService _reportReview = ReportReviewService();

    void _handleReportReview(
        BuildContext context, String reason, String reportId) async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('token');

        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be logged in to post a review.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final message = await _reportReview.createAccountReportReview(
          accountReportId: reportId,
          reason: reason,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Error submitting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          AssetImage('assets/images/defaultAvatar.png'),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.public,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              getTimeAgo(report.timestamp
                                  .add(const Duration(hours: 7))),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Menu action
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            if (report.imgs.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  report.imgs.first.img,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    // Show shimmer while loading
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IntrinsicWidth(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.directions),
                        onPressed: () {
                          // Logic chỉ đường
                        },
                      ),
                      const Text(
                        'Go map',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IntrinsicWidth(
                  child: ReportDropdown(
                    onSelected: (reason) {
                      _handleReportReview(context, reason, reportId);
                      // Gửi API hoặc hiển thị xác nhận
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
