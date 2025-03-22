import 'package:flutter/material.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:provider/provider.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemName;

  const ItemDetailPage({
    super.key,
    required this.itemName
  });

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
      future: context.read<MyAppState>().supabase
        .from('items')
        .select('*')
        .match({'ingredient_name': itemName})
        .maybeSingle(),
      builder: (context, item) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              '이름: ${item?['ingredient_name']}',
              style: Theme.of(context).textTheme.titleLarge
            ),
            Text(
              '유통기한: ${item?['expiration_date'] ?? ''}',
              style: Theme.of(context).textTheme.bodyLarge
            ),
            Text(
              '설명: ${item?['description']}',
              style: Theme.of(context).textTheme.bodyLarge
            ),
          ],
        );
      },
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(item['ingredient_name'] ?? '상세 정보'),
    //   ),
    //   body: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text('이름: ${item['ingredient_name']}', style: Theme.of(context).textTheme.titleLarge),
    //         const SizedBox(height: 10),
    //         Text('유통기한: ${item['expiration_date'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
    //         const SizedBox(height: 10),
    //         if (item['description'] != null)
    //           Text('설명: ${item['description']}', style: Theme.of(context).textTheme.bodyLarge),
    //       ],
    //     ),
    //   ),
    // );
  }
}