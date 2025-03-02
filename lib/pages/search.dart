import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_ice_box/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // 사용자가 입력할 때마다 debounce 처리 후 자동완성 제안을 요청
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _getSuggestions(query);
    });
  }

  // Supabase에서 검색어로 시작하는 아이템 조회
  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    final supabase = context.read<MyAppState>().supabase;
    try {
      final data = await supabase
          .from('items')
          .select('*')
          .ilike('ingredient_name', '$query%')
          .limit(10);
      setState(() {
        _suggestions = data as List<dynamic>;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색 중 에러 발생: $error')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
      ),
      body: Column(
        children: [
          // 검색 입력창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '검색어 입력',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _getSuggestions(_controller.text),
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          // 자동완성 제안 목록
          if (_suggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion['ingredient_name']),
                    onTap: () {
                      // 제안을 탭하면 상세 정보 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ItemDetailPage(item: suggestion),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(child: Text('검색 결과가 없습니다.')),
            ),
        ],
      ),
    );
  }
}

// 검색 결과 상세 정보를 보여주는 페이지
class ItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['ingredient_name'] ?? '상세 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이름: ${item['ingredient_name']}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text('유통기한: ${item['expiration_date'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            if (item['description'] != null)
              Text('설명: ${item['description']}', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
