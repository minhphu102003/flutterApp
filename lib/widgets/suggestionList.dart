import 'package:flutter/material.dart';

class SuggestionsList extends StatelessWidget {
  final List<String> suggestions; // Danh sách gợi ý
  final Function(String) onSuggestionSelected; // Hàm callback khi chọn gợi ý
  final double top;
  const SuggestionsList({
    Key? key,
    required this.suggestions,
    required this.onSuggestionSelected,
    this.top = 90,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 10,
      right: 10,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(suggestions[index]),
              onTap: () => onSuggestionSelected(suggestions[index]),
            );
          },
        ),
      ),
    );
  }
}
