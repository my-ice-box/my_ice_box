import 'package:flutter/material.dart';
import 'package:my_ice_box/pages/home.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Ice Box',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _index = 2;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'note', 'icon': Icons.note},
      {'label': 'search', 'icon': Icons.search},
      {'label': 'home', 'icon': Icons.home},
      {'label': 'shortcut', 'icon': Icons.star_rounded},
      {'label': 'settings', 'icon': Icons.settings},
    ];
    var label = items[_index]['label'] as String;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('This is $label Page'),
      ),
      body: <Widget>[
        const Placeholder(),
        const Placeholder(),
        const HomePage(),
        const Placeholder(),
        const Placeholder(),
      ][_index],
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: "I'm tooltip!",
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        showSelectedLabels: true,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          for (var item in items)
            BottomNavigationBarItem(
              icon: Icon(item['icon'] as IconData),
              label: item['label'] as String,
            ),
        ],
        onTap: (tappedIndex) => setState(() { _index = tappedIndex; }),
      ),
    );
  }
}
