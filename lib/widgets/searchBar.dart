import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import '../theme/colors.dart';

class SearchBarBar extends StatefulWidget {
  final FloatingSearchBarController fsc;
  final ValueChanged<bool> onToggle;

  const SearchBarBar({
    super.key,
    required this.fsc,
    required this.onToggle,
  });

  @override
  State<SearchBarBar> createState() {
    return _SearchBarState();
  }
}

class _SearchBarState extends State<SearchBarBar> {
  List<Map<String, String>> recentSearches = [
    {'time': '10:30 AM', 'query': 'New York'},
    {'time': '11:00 AM', 'query': 'Tokyo'},
    {'time': '12:00 PM', 'query': 'London'},
    {'time': '1:30 PM', 'query': 'Sydney'},
  ];

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      controller: widget.fsc,
      hint: 'Search...',
      clearQueryOnClose: false,
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeIn,
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction(
          showIfOpened: true,
          showIfClosed: false,
          child: CircularButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              widget.fsc.close();
            },
          ),
        ),
      ],
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.mic),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      onQueryChanged: (query) {
        // Gọi callback khi SearchBar mở
        if (query.isNotEmpty && !widget.fsc.isOpen) {
          widget.onToggle(true);
        } else if (query.isEmpty) {
          widget.onToggle(false); // Đóng khi query trống
        }
      },
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: recentSearches.length,
              itemBuilder: (context, index) {
                var searchItem = recentSearches[index];
                return ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.grey),
                  title: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(searchItem['query'] ?? ''),
                        Text(searchItem['time'] ?? '', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  onTap: () {
                    widget.fsc.query = searchItem['query'] ?? '';
                    widget.fsc.close();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
