import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../models/paginated_data.dart';
import 'reportItem.dart';

class ReportList extends StatelessWidget {
  final Future<PaginatedData<Report>> futureReports;

  const ReportList({super.key, required this.futureReports});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaginatedData<Report>>(
      future: futureReports,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return const Center(child: Text('No reports found.'));
        } else {
          final reports = snapshot.data!.data;
          return Column(
            children: reports.map((report) => ReportItem(report: report)).toList(),
          );
        }
      },
    );
  }
}
