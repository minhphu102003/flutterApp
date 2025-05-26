import 'package:flutter/material.dart';
import 'package:flutterApp/models/reportV2.dart';
import 'package:flutterApp/services/reportServiceV2.dart';
import 'package:flutterApp/widgets/shimmerRecentVideoList.dart';
import 'package:flutterApp/widgets/videoFullScreenPage.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Videos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                ShimmerRecentVideoList(),
              ],
            ),
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
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPreview(
                          videoUrl: videoUrl,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VideoFullScreenPage(videoUrl: videoUrl),
                              ),
                            );
                          },
                        ),
                        const Positioned(
                          top: 10,
                          left: 10,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundImage:
                                AssetImage('assets/images/defaultAvatar.png'),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              report.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
