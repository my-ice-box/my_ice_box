import 'package:flutter/material.dart';
import 'package:my_ice_box/pages/home.dart';
import 'package:my_ice_box/pages/note.dart';
import 'package:my_ice_box/pages/profile.dart';
import 'package:my_ice_box/pages/AddProductPage.dart';
import 'package:my_ice_box/widgets/text_placeholder.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_ice_box/pages/search.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment("SUPABASE_URL"),
    anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY"),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  () async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: const String.fromEnvironment("SUPABASE_DUMMY_EMAIL"),
      password: const String.fromEnvironment("SUPABASE_DUMMY_PASSWORD"),
    );
  }();

  runApp(ChangeNotifierProvider(
    create: (context) => MyAppState(),
    child: const MyApp(),
  ));
}

class MyAppState with ChangeNotifier {
  final supabase = Supabase.instance.client;
  PostgrestList items = [];
  PostgrestList notes = [];

  static const classTable = ['place', 'category'];
  PostgrestList places = [];
  PostgrestList categories = [];

  Future<void> fetchItems() async {
    items = await supabase.from('items')
      .select('ingredient_name, amount, place_name, added_at, expiration_date,' 
        '...ingredient!inner(ingredient_name, category_name)'
      );

    // notifyListeners();
  }

  Future<void> fetchNotes() async {
    notes = await supabase.from('notes')
      .select('title, content, updated_at');

    // notifyListeners();
  }

  Future<void> fetchAll() async {
    places = await supabase.from('place')
      .select('*');
    categories = await supabase.from('category')
      .select('*');

    await fetchItems();
    await fetchNotes();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.fetchAll();

    final appTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
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

    return MaterialApp(
      title: 'My Ice Box',
      theme: appTheme,
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
  /// 앱 상단 도구들
  AppBar get appBar {
    final profile = IconButton(
      icon: const Icon(Icons.account_circle),
      tooltip: 'Profile',
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      ),
    );
    final search = IconButton(
      icon: const Icon(Icons.search),
      tooltip: 'search',
      onPressed: () => showSearch(context: context, delegate: DataSearch()),
    );
    final notification = IconButton(
      icon: const Icon(Icons.notifications),
      tooltip: 'Notifications',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('There are no notifications.'),
            duration: Duration(milliseconds: 320),
          ),
        );
      },
    );

    return AppBar(
      leading: profile,
      title: Text('Ice Box'),
      actions: [
        search,
        notification,
      ],
    );
  }

  /// 메인 페이지에서 이동 가능한 페이지들
  final pages = [
    NotePage(),
    TextPlaceholder(text: 'search'),
    HomePage(),
    TextPlaceholder(text: 'star'),
    TextPlaceholder(text: 'settings'),
  ];
  /// 현재 보여줄 페이지 index
  int currentPageIndex = 0;
  /// 현재 보여줄 페이지
  Widget get page => pages[currentPageIndex];

  /// 물품 추가 버튼
  FloatingActionButton get floatingActionButton => FloatingActionButton(
    onPressed: () => Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => const AddProductPage()
      ),
    ),
    tooltip: '제품 추가',
    child: const Icon(Icons.add),
  );

  /// 페이지 이동 버튼
  BottomNavigationBar bottomNavigationBar(BuildContext context) {
    final numNote = context.watch<MyAppState>().notes.length;

    final noteNavigator = BottomNavigationBarItem(
      icon: Badge(
        label: Text('$numNote'),
        child: const Icon(Icons.note_outlined),
      ),
      activeIcon: Badge(
        label: Text('$numNote'),
        child: const Icon(Icons.note),
      ),
      tooltip: '노트',
      label: '노트',
    );
    const searchNavigator = BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      tooltip: '검색',
      label: '검색',
    );
    const homeNavigator = BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      tooltip: '홈',
      label: '홈',
    );
    const starNavigator = BottomNavigationBarItem(
      icon: Icon(Icons.star_outline_rounded),
      activeIcon: Icon(Icons.star_rounded),
      tooltip: '재고 처리',
      label: '재고 처리',
    );
    const settingsNavigator = BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      tooltip: '설정',
      label: '설정',
    );

    return BottomNavigationBar(
      onTap: (tappedIndex) => tappedIndex != 1 ?
        setState(() => currentPageIndex = tappedIndex) :
        showSearch(context: context, delegate: DataSearch()),
      currentIndex: currentPageIndex,
      type: BottomNavigationBarType.fixed,
      items: [
        noteNavigator, searchNavigator, homeNavigator,
        starNavigator, settingsNavigator,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: page,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar(context),
    );
  }
}
