import 'package:flutter/material.dart';
import 'package:my_ice_box/pages/home.dart';
import 'package:my_ice_box/pages/profile.dart';
import 'package:my_ice_box/pages/AddProductPage.dart'; // AddProductPage를 import
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
        home: const MainPage(),
      ),
    );
  }
}

/// 앱 전체에서 공유할 Supabase 클라이언트를 관리
class MyAppState with ChangeNotifier {
  final supabase = Supabase.instance.client;
}

/// 하단 BottomNavigationBar로 여러 페이지를 전환하는 메인 페이지
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 기본으로 HomePage(메인 화면)를 보여주도록 인덱스 2 선택
  int currentPageIndex = 2;
  int numNote = 5; // Badge에 표시할 숫자

  // 각 페이지 위젯을 IndexedStack으로 관리하면, 페이지 상태가 유지됨.
  final List<Widget> pages = [
    Center(child: Text("주요 품목 페이지는 준비 중입니다.")),
    Center(child: Text("검색 페이지는 준비 중입니다.")),
    const HomePage(),
    Center(child: Text("요약 페이지는 준비 중입니다.")),
    Center(child: Text("설정 페이지는 준비 중입니다.")),
  ];

  // 각 페이지에 대응하는 AppBar 제목
  final List<String> pageTitles = const [
    '주요 품목',
    '검색',
    '메인화면',
    '요약',
    '설정',
  ];

  /// FloatingActionButton을 누르면 제품 추가 페이지로 이동
  void _onFabPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[currentPageIndex]),
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Profile',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        actions: [
          IconButton(
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
          ),
        ],
      ),
      // IndexedStack을 사용하여 페이지 전환 시 각 페이지 상태 유지
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: '제품 추가',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: [
          // Badge 위젯으로 숫자를 표시하는 항목 (예: 알림 수나 품목 수)
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$numNote'),
              child: const Icon(Icons.note_outlined),
            ),
            activeIcon: Badge(
              label: Text('$numNote'),
              child: const Icon(Icons.note),
            ),
            tooltip: '주요 품목',
            label: '주요 품목',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            tooltip: '검색',
            label: '검색',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            tooltip: '메인화면',
            label: '메인화면',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.star_outline_rounded),
            activeIcon: Icon(Icons.star_rounded),
            tooltip: '요약',
            label: '요약',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            tooltip: '설정',
            label: '설정',
          ),
        ],
      ),
    );
  }
}
