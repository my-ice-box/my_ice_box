import 'package:flutter/material.dart';
import 'package:my_ice_box/components/search_text.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/pages/item_detail.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:provider/provider.dart';

class DataSearch extends SearchDelegate<String> {
  List<Map<String, dynamic>> cache = [];

  DataSearch({super.searchFieldLabel});

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => Navigator.pop(context),
    icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    ),
  );

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      onPressed: () => query = '',
      icon: const Icon(Icons.clear),
    )
  ];

  

  @override
  Widget buildSuggestions(BuildContext context) {
    Widget fetchSuggestions() {
      return ListView.builder(
        itemCount: cache.length,
        itemBuilder: (context, index) {
          final itemName = cache[index]['ingredient_name'] as String;

          return ListTile(
            leading: const Icon(Icons.search),
            title: SearchText(
              text: itemName,
              matchedIndex: query.length,
            ),
            onTap: () => query = itemName,
          );
        },
      );
    }

    return CustomFutureBuilder(
      future: context.read<MyAppState>().supabase
        .from('items')
        .select('ingredient_name')
        .ilike('ingredient_name', '$query%')
        .limit(10),
      onLoading: fetchSuggestions(),
      builder: (context, snapshot) {
        if(snapshot.isNotEmpty) {
          cache = snapshot;
        }
        return fetchSuggestions();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => ItemDetailPage(itemName: query);
}
