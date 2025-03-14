import 'package:flutter/material.dart';
import 'package:my_ice_box/components/search_text.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/pages/search.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:provider/provider.dart';

class DataSearch extends SearchDelegate<String> {
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
    return CustomFutureBuilder(
      future: context.read<MyAppState>().supabase
        .from('items')
        .select('*')
        .ilike('ingredient_name', '$query%')
        .limit(10),
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.length,
          itemBuilder: (context, index) {
            final item = snapshot[index];

            return ListTile(
              leading: const Icon(Icons.search),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailPage(
                    item: item,
                  ),
                ),
              ),
              title: SearchText(
                text: item['ingredient_name'] as String,
                matchedIndex: query.length,
              ),
            );
          },
        );
      },
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
