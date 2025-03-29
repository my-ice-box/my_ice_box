import 'package:flutter/material.dart';
import 'package:my_ice_box/components/search_text.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/pages/item_detail.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final supabase = context.read<MyAppState>().supabase;

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

    Future<PostgrestList> searchSuggestions() async {
      final results = await supabase.from('items')
        .select('ingredient_name')
        .ilike('ingredient_name', '%$query%')
        .limit(20);

      const Map<String, List<String>> choseongRange = {
        'ㄱ': ['가', '깋'],
        'ㄴ': ['나', '닣'],
        'ㄷ': ['다', '딯'],
        'ㄹ': ['라', '맇'],
        'ㅁ': ['마', '밓'],
        'ㅂ': ['바', '빟'],
        'ㅅ': ['사', '싷'],
        'ㅇ': ['아', '잏'],
        'ㅈ': ['자', '짛'],
        'ㅊ': ['차', '칳'],
        'ㅋ': ['카', '킿'],
        'ㅌ': ['타', '팋'],
        'ㅍ': ['파', '핗'],
        'ㅎ': ['하', '힣'],
      };

      final lastIndex = query.isNotEmpty ? query.length-1 : 0;
      final lastChar = query[lastIndex];
      final prefix = query.substring(0, lastIndex);

      if(choseongRange.containsKey(lastChar)){
        final range = choseongRange[lastChar]!;

        final choseongMatch = await supabase.from('items')
          .select('ingredient_name')
          .gte('ingredient_name', prefix + range[0])
          .lte('ingredient_name', prefix + range[1])
          .limit(20);
        results.addAll(choseongMatch);
      }

      return results;
    }

    return CustomFutureBuilder(
      future: searchSuggestions(),
      onLoading: fetchSuggestions(),
      builder: (context, snapshot) {
        cache = snapshot;
        if(snapshot.isNotEmpty) {
        }
        return fetchSuggestions();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => ItemDetailPage(itemName: query);
}
