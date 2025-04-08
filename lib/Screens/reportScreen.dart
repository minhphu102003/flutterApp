import 'package:flutter/material.dart';
import '../services/reportService.dart';
import '../models/report.dart';
import '../models/paginated_data.dart';
import '../widgets/recentVideoSection.dart';
import '../widgets/reportList.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();
  late Future<PaginatedData<Report>> _futureReports;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  void _fetchReports() {
    setState(() {
      _futureReports = _reportService.fetchAccountReport(
        page: 1,
        limit: 10,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Screen')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(16.0)),
            const Divider(),
            const RecentVideosSection(),
            const Divider(),
            ReportList(futureReports: _futureReports),
          ],
        ),
      ),
    );
  }
}
