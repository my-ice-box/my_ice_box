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
