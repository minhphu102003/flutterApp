import 'package:flutter/material.dart';
import '../constants/reportReasons.dart';

class ReportDropdown extends StatelessWidget {
  final void Function(String) onSelected;

  const ReportDropdown({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () async {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        final Offset position =
            button.localToGlobal(Offset.zero, ancestor: overlay);

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            position.dx,
            position.dy + button.size.height,
            position.dx + button.size.width,
            position.dy,
          ),
          items: reportReasons.map((item) {
            return PopupMenuItem<String>(
              value: item['value']!,
              child: Text(item['label']!),
            );
          }).toList(),
        );

        if (selected != null) {
          if (selected == 'other') {
            final customReason = await showDialog<String>(
              context: context,
              builder: (context) {
                final TextEditingController controller =
                    TextEditingController();
                return AlertDialog(
                  title: const Text('Enter report reason'),
                  content: TextFormField(
                    controller: controller,
                    maxLines: 3,
                    minLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Type your reason',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final input = controller.text.trim();
                        Navigator.pop(context, input);
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                );
              },
            );

            if (customReason != null && customReason.isNotEmpty) {
              onSelected(customReason);
            }
          } else {
            onSelected(selected);
          }
        }
      },
      child: const Row(
        children: [
          Icon(Icons.report, size: 20, color: Colors.grey),
          SizedBox(width: 4),
          Text(
            'Report',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
