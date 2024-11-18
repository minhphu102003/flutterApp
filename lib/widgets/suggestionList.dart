import 'package:flutter/material.dart';

class SuggestionsList extends StatelessWidget {
  final List<String> suggestions; // Danh sách gợi ý
  final Function(String) onSuggestionSelected; // Hàm callback khi chọn gợi ý

  const SuggestionsList({
    Key? key,
    required this.suggestions,
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 10,
      right: 10,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
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
