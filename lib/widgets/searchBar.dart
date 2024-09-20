import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';


import '../theme/colors.dart';

class SearchBarBar extends StatefulWidget{
  final FloatingSearchBarController fsc;

  const SearchBarBar({
    super.key,
    required this.fsc,
  });

  @override
  State<SearchBarBar> createState() {
    return _SearchBarState();
  }
}

class _SearchBarState extends State<SearchBarBar>{



  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      controller: widget.fsc,
      hint: 'Search...',
      clearQueryOnClose: false,
      transitionDuration: Duration(milliseconds: 300),
      transitionCurve: Curves.easeIn,
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place), 
            onPressed: (){}),
        ),
        FloatingSearchBarAction(
          showIfOpened: true,
          showIfClosed: false,
          child: CircularButton(
            icon: const Icon(Icons.chevron_left),   
            onPressed: (){
              widget.fsc.close();
            }),
        )
      ],
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.mic), 
            onPressed: (){},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        )
      ],
      builder: (context, transition) {
        return ClipRect(
          child: Material(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(title: Text('Result 1'),),
                ListTile(title: Text('Result 2'),),
              ],
            ),
          ),   
        );
      }
    );
  }

}