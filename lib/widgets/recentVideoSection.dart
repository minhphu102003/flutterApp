import 'package:flutter/material.dart';
import 'package:flutterApp/models/reportV2.dart';
import 'package:flutterApp/services/reportServiceV2.dart';
import 'package:flutterApp/widgets/videoPreview.dart';

class RecentVideosSection extends StatelessWidget {
  const RecentVideosSection({super.key});

  Future<List<AccountReportV2>> _fetchRecentVideos() async {
    final response = await ReportServiceV2().getReports(limit: 10);
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AccountReportV2>>(
      future: _fetchRecentVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Failed to load recent videos'),
          );
        }

        final reports = snapshot.data!;
        if (reports.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No recent videos found'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Videos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final videoUrl = report.mediaFile?.url ?? '';
                    final String username = report.username;
                    return GestureDetector(
                      onTap: () {
                        // TODO: Navigate to full video player
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: VideoPreview(videoUrl: videoUrl),
                          ),
                          const Icon(
                            Icons.play_circle_outline,
                            color: Color.fromARGB(255, 175, 174, 172),
                            size: 50,
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.grey
                                    .withOpacity(0.6), 
                                borderRadius:
                                    BorderRadius.circular(30), // Bo tròn
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 12,
                                    backgroundImage: AssetImage(
                                        'assets/images/defaultAvatar.png'),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    report.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                          color: Colors.black54,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
