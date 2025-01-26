import 'package:flutter/material.dart';
import 'package:my_ice_box/components/search_text.dart';

class DataSearch extends SearchDelegate<String> {


  final recentSearch = [
    'apple',
    'banana',
    'orange',
    'grape',
    'watermelon'
  ];

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(
          Icons.clear,
        ),
      ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestion = recentSearch.where(
      (element) => element.startsWith(query)
    ).toList();
    
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.search),
        onTap: () => showResults(context),
        title: SearchText(
          text: suggestion[index],
          matchedIndex: query.length,
        ),
      ),
      itemCount: suggestion.length,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        "${query.length}",
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }
}

// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // return SearchAnchor.bar(
//     //   barHintText: 'Search',
//     //   suggestionsBuilder: (context, controller) {
//     //     return List<ListTile>.generate(
//     //       5, (index) {
//     //         return ListTile(
//     //           title: Text('item $index'),
//     //           onTap: () {}
//     //         );
//     //       }
//     //     );
//     //   }
//     // );

//     return SearchAnchor(
//       builder: (context, controller) {
//         return SearchBar(
//           hintText: 'Search',
//           controller: controller,
//           autoFocus: true,
//           padding: const WidgetStatePropertyAll<EdgeInsets>(
//             EdgeInsets.symmetric(horizontal: 16.0)
//           ),
//           onTap: () => controller.openView(),
//           onChanged: (_) => controller.openView(),
//           onSubmitted: (_) => controller.closeView(null),
//           leading: const Icon(Icons.search),
//         );
//       },
//       suggestionsBuilder: (context, controller) {
//         return List<ListTile>.generate(5, (index) {
//           final String item = 'item $index';
//           return ListTile(
//             title: Text(item),
//             onTap: () {}
//           );
//         });
//       },
//     );

//     return AppBar(
//       title: InkWell(
//         onTap: () {
//           if(context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 duration: Duration(seconds: 1),
//                 content: Text('search title'),
//               ),
//             );
//           }
//         },
//         onLongPress: () {
//           if(context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 duration: Duration(seconds: 1),
//                 content: Text('search title long press'),
//               ),
//             );
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: TextField(
//             decoration: InputDecoration(
//               label: const Icon(Icons.search),
//               hintText: 'Search',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }