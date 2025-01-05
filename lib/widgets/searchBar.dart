import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String) onSearchChanged;
  final void Function() onSearchSubmitted;
  final void Function() onClear;

  final double top;
  final double left;
  final double right;

  const SearchBar({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClear,
    this.top = 40.0, // Vị trí mặc định cách cạnh trên 40px
    this.left = 10.0, // Vị trí mặc định cách cạnh trái 10px
    this.right = 10.0, // Vị trí mặc định cách cạnh phải 10px
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: top,
          left: left,
          right: right,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for a location...',
                      border: InputBorder.none,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: onSearchSubmitted,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClear,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
