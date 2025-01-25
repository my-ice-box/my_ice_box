import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  // how to close keyboard automatically?
  // https://stackoverflow.com/questions/68091169/how-to-close-keyboard-automatically
  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (context, controller) {
        return SearchBar(
          hintText: 'Search',
          controller: controller,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)
          ),
          onTap: () => controller.openView(),
          // onChanged: (_) => controller.openView(),
          onSubmitted: (_) => controller.closeView(_),
          leading: const Icon(Icons.search),
        );
      },
      suggestionsBuilder: (context, controller) {
        return List<ListTile>.generate(5, (index) {
          final String item = 'item $index';
          return ListTile(
            title: Text(item),
            onTap: () {}
          );
        });
      },
    );

    return AppBar(
      title: InkWell(
        onTap: () {
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 1),
                content: Text('search title'),
              ),
            );
          }
        },
        onLongPress: () {
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 1),
                content: Text('search title long press'),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              label: const Icon(Icons.search),
              hintText: 'Search',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}