import 'package:flutter/material.dart';
import 'package:my_ice_box/pages/home.dart';
import 'package:my_ice_box/pages/item_box.dart';
import 'package:my_ice_box/pages/profile.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment("SUPABASE_URL"),
    anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY"),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Colors.blue,
        secondary: Colors.amber,
        tertiary: Color(0xFF6200EE),
        surface: Colors.white,
        error: Color(0xFFC51162),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white,
      ),
      textTheme: Typography.blackCupertino,
    );

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'My Ice Box',
        theme: appTheme,
        home: const MainPage(),
      ),
    );
  }
}

class MyAppState with ChangeNotifier {
  // Get a reference your Supabase client
  final supabase = Supabase.instance.client;
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var currentPageIndex = 2;

  var numNote = 5;

  @override
  Widget build(BuildContext context) {
    final pageName =
        ['note', 'search', 'home', 'shortcut', 'settings'][currentPageIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.account_circle),
            tooltip: 'profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            }),
        title: Text('This is $pageName Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'notification',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(milliseconds: 320),
                content: Text('There is no notification.'),
              ));
            },
          ),
        ],
      ),
      body: <Widget>[
        const Placeholder(
          child: Center(child: Text('note doesn\'t exist')),
        ),
        const Placeholder(),
        const HomePage(),
        ItemBox(),
        const Placeholder(),
      ][currentPageIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'This is action button',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (tappedIndex) => setState(() {
          currentPageIndex = tappedIndex;
        }),
        currentIndex: currentPageIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$numNote'),
              child: Icon(Icons.note_outlined),
            ),
            activeIcon: Badge(
              label: Text('$numNote'),
              child: Icon(Icons.note),
            ),
            tooltip: 'This is note',
            label: 'note',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            tooltip: 'This is search',
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            tooltip: 'This is home',
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline_rounded),
            activeIcon: Icon(Icons.star_rounded),
            tooltip: 'This is shortcut',
            label: 'shortcut',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            tooltip: 'This is settings',
            label: 'settings',
          ),
        ],
      ),
    );
  }
}
