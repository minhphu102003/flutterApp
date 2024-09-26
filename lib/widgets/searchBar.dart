import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import '../theme/colors.dart';

// Widget cho thanh tìm kiếm nổi
class SearchBarBar extends StatefulWidget {
  final FloatingSearchBarController fsc; // Controller cho thanh tìm kiếm
  final ValueChanged<bool> onToggle; // Callback để quản lý trạng thái mở/đóng

  const SearchBarBar({
    super.key,
    required this.fsc,
    required this.onToggle,
  });

  @override
  State<SearchBarBar> createState() {
    return _SearchBarState(); // Trả về trạng thái của SearchBar
  }
}

class _SearchBarState extends State<SearchBarBar> {
  // Danh sách tìm kiếm gần đây
  List<Map<String, String>> recentSearches = [
    {'time': '10:30 AM', 'query': 'New York'},
    {'time': '11:00 AM', 'query': 'Tokyo'},
    {'time': '12:00 PM', 'query': 'London'},
    {'time': '1:30 PM', 'query': 'Sydney'},
  ];

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      controller: widget.fsc, // Gán controller cho thanh tìm kiếm
      hint: 'Search...', // Gợi ý cho người dùng
      clearQueryOnClose: false, // Không xóa truy vấn khi đóng
      transitionDuration: const Duration(milliseconds: 300), // Thời gian chuyển tiếp
      transitionCurve: Curves.easeIn, // Đường cong chuyển tiếp
      transition: CircularFloatingSearchBarTransition(), // Hiệu ứng chuyển tiếp
      leadingActions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place), // Biểu tượng vị trí
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction(
          showIfOpened: true,
          showIfClosed: false,
          child: CircularButton(
            icon: const Icon(Icons.chevron_left), // Biểu tượng quay lại
            onPressed: () {
              widget.fsc.close(); // Đóng thanh tìm kiếm
            },
          ),
        ),
      ],
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.mic), // Biểu tượng mic
            onPressed: () {}, // Hành động cho mic
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false, // Hành động để xóa khi không mở
        ),
      ],
      onQueryChanged: (query) {
        // Gọi callback khi thanh tìm kiếm mở
        if (query.isNotEmpty && !widget.fsc.isOpen) {
          widget.onToggle(true); // Mở thanh tìm kiếm
        } else if (query.isEmpty) {
          widget.onToggle(false); // Đóng thanh tìm kiếm nếu không có truy vấn
        }
      },
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // Bo tròn góc cho dropdown
          child: Material(
            color: Colors.white, // Màu nền cho dropdown
            elevation: 4.0, // Độ cao bóng đổ
            child: ListView.builder(
              shrinkWrap: true, // Giúp danh sách cuộn mượt mà
              itemCount: recentSearches.length, // Số lượng mục trong danh sách
              itemBuilder: (context, index) {
                var searchItem = recentSearches[index]; // Lấy mục tìm kiếm
                return ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.grey), // Biểu tượng thời gian
                  title: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black, // Màu viền dưới
                          width: 0.5, // Độ dày viền
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Căn trái cho văn bản
                      children: [
                        Text(searchItem['query'] ?? ''), // Truy vấn tìm kiếm
                        Text(searchItem['time'] ?? '', style: TextStyle(color: Colors.grey)), // Thời gian tìm kiếm
                      ],
                    ),
                  ),
                  onTap: () {
                    widget.fsc.query = searchItem['query'] ?? ''; // Thiết lập truy vấn
                    widget.fsc.close(); // Đóng thanh tìm kiếm
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
