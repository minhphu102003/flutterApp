import 'package:flutter/material.dart';
import '../services/reportService.dart';
import '../models/report.dart';
import '../models/paginated_data.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';


class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();
  late Future<PaginatedData<Report>> _futureReports;
  // String serverUrl = kIsWeb ? 'http://127.0.0.1:8000/uploads/' : 'http://10.0.2.2:8000/uploads/';

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  void _fetchReports() {
    setState(() {
      _futureReports = _reportService.fetchAccountReport(
        page: 1, // Default to the first page
        limit: 10, // Limit to 10 items
      );
    });
    print(_futureReports);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text('Report Screen'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần trên cùng: Người dùng đăng bài
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150'), // Ảnh avatar mẫu
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'What are you thinking?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () {
                      // Thêm logic để upload ảnh
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            // Danh sách video và bài viết
            Column(
              children: [
                // Phần video gần nhất
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Videos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 220, // Chiều cao đủ để chứa video và avatar
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(10, (index) {
                              // Hiển thị 10 video mẫu
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Logic phát video
                                  },
                                  child: Stack(
                                    alignment: Alignment.topLeft,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    3 -
                                                16, // Chiều rộng mỗi video
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: const DecorationImage(
                                            image: NetworkImage(
                                                'https://via.placeholder.com/300'), // Ảnh mẫu video
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        top: 10,
                                        left: 10,
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                              'https://via.placeholder.com/150'), // Avatar mẫu
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              FutureBuilder<PaginatedData<Report>>(
              future: _futureReports,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error.toString()}'));
                } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                  return const Center(child: Text('No reports found.'));
                } else {
                  final reports = snapshot.data!.data;

                  return Column(
                    children: reports.map((report) {
                      // Định dạng thời gian
                        DateTime adjustedTimestamp = report.timestamp.add(Duration(hours: 7));
                        String formattedTime = DateFormat('HH:mm dd/MM/yyyy').format(adjustedTimestamp);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      'https://via.placeholder.com/150'),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  report.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              report.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            // Hiển thị thời gian
                            Text(
                              '$formattedTime',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (report.imgs.isNotEmpty)
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    // image: NetworkImage('$serverUrl${report.imgs.first.img}'),
                                    image: NetworkImage('${report.imgs.first.img}'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.directions),
                                  onPressed: () {
                                    // Logic chỉ đường
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.report),
                                  onPressed: () {
                                    // Logic báo cáo bài viết
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
              )
              ],
            ),
          ],
        ),
      ),
    );
  }
}





