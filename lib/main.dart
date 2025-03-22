import 'package:flutter/material.dart';
import 'package:my_ice_box/pages/home.dart';
import 'package:my_ice_box/pages/item_box.dart';
import 'package:my_ice_box/pages/note.dart';
import 'package:my_ice_box/pages/profile.dart';
import 'package:my_ice_box/pages/AddProductPage.dart';
import 'package:my_ice_box/widgets/text_placeholder.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_ice_box/pages/inventory.dart';
import 'package:my_ice_box/pages/search.dart';

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
  /// Supabase 클라이언트 (앱 전체에서 공유)
  final supabase = Supabase.instance.client;
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// Note Badge에 표시할 숫자
  int get numNote {
    // TODO: supabase에서 note 불러오기
    return 2;
  }

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
    InventoryPage(title: '재고 처리'),
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
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
