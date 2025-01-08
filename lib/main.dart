import 'package:flutter/material.dart';
import 'package:my_ice_box/pages/home.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'My Ice Box',
      theme: themeData,
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
  var _counter = 0;

  void _incrementCounter() {
    setState(() { _counter++; });
  }

  @override
  Widget build(BuildContext context) {
    var label = [
      'note',
      'search',
      'home',
      'shortcut',
      'settings',
    ][_index];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('This is ($label) Page'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 15,
        ),
        child: <Widget>[
          const Placeholder(),
          const Placeholder(),        
          HomePage(numPushed: _counter),
          const Placeholder(),
          const Placeholder(),
        ][_index],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        showSelectedLabels: true,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'note'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'search'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rounded),
            label: 'shortcut'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings'
          ),
        ],
        onTap: (tappedIndex) => setState(() { _index = tappedIndex; }),
      ),
    );
  }
}
