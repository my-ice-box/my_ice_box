import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── 앱 내부 페이지 ─────────────────────────────────────────────
import 'package:my_ice_box/pages/home.dart';
import 'package:my_ice_box/pages/item_box.dart';
import 'package:my_ice_box/pages/note.dart';
import 'package:my_ice_box/pages/profile.dart';
import 'package:my_ice_box/pages/AddProductPage.dart';
import 'package:my_ice_box/pages/inventory.dart';
import 'package:my_ice_box/pages/search_v2.dart';
import 'package:my_ice_box/widgets/text_placeholder.dart';

// 🔹 새로 만든 로그인 페이지
import 'package:my_ice_box/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'My Ice Box',
        theme: appTheme,
        // 🔹 앱을 실행하면 가장 먼저 LoginPage 가 나타납니다
        home: const LoginPage(),
      ),
    );
  }
}

/// 앱 전역에서 Supabase 클라이언트를 공유
class MyAppState with ChangeNotifier {
  final supabase = Supabase.instance.client;
}

/// ───────────────────────────────
/// 메인(홈) 페이지 - 로그인 이후 진입
/// ───────────────────────────────
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// Note 배지에 표시할 숫자 (임시)
  int get numNote => 2; // TODO: Supabase 에서 note 불러오기

  // ── AppBar ────────────────────────────────────────────────
  AppBar get appBar {
    final profile = IconButton(
      icon: const Icon(Icons.account_circle),
      tooltip: 'Profile',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
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
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no notifications.'),
          duration: Duration(milliseconds: 320),
        ),
      ),
    );

    return AppBar(
      leading: profile,
      title: const Text('Ice Box'),
      actions: [search, notification],
    );
  }

  // ── 페이지 목록 ────────────────────────────────────────────
  final pages = [
    NotePage(),
    const TextPlaceholder(text: 'search'),
    const HomePage(),
    const InventoryPage(title: '재고 처리'),
    const TextPlaceholder(text: 'settings'),
  ];

  int currentPageIndex = 0;
  Widget get page => pages[currentPageIndex];

  // ── FloatingActionButton ─────────────────────────────────
  FloatingActionButton get floatingActionButton => FloatingActionButton(
    tooltip: '제품 추가',
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductPage()),
    ),
    child: const Icon(Icons.add),
  );

  // ── BottomNavigationBar ─────────────────────────────────
  BottomNavigationBar get bottomNavigationBar {
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
      currentIndex: currentPageIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (tapped) => tapped != 1
          ? setState(() => currentPageIndex = tapped)
          : showSearch(context: context, delegate: DataSearch()),
      items: [
        noteNavigator,
        searchNavigator,
        homeNavigator,
        starNavigator,
        settingsNavigator,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: page,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
