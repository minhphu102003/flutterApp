import 'package:flutter/material.dart';

class RouteInstructions extends StatefulWidget {
  final List<String> routeInstructions;
  final String? travelTime;
  final double bottomPosition;

  const RouteInstructions({
    super.key,
    required this.routeInstructions,
    this.travelTime,
    this.bottomPosition = 50,
  });

  @override
  State<RouteInstructions> createState() => _RouteInstructionsState();
}

class _RouteInstructionsState extends State<RouteInstructions> {
  int activeStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    String title = 'Detailed Directions';
    if (widget.travelTime != null && widget.travelTime!.isNotEmpty) {
      title += ' (${widget.travelTime!})';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: widget.routeInstructions.length + 1,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    final instruction = widget.routeInstructions[index - 1];
                    final isActive = index - 1 == activeStepIndex;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          activeStepIndex = index - 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.blue.shade50 : Colors.white,
                          border: const Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isActive ? Icons.play_arrow : Icons.navigation,
                              size: 20,
                              color: isActive ? Colors.green : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                instruction,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      isActive ? Colors.black87 : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
