import 'package:flutter/material.dart';
import 'package:my_ice_box/main.dart';
import 'package:my_ice_box/widgets/custom_future_builder.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collection/collection.dart';

class InventoryPage extends StatelessWidget {
  final String title;

  const InventoryPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (title == '재고 처리') {
      // nearExpiryThreshold: 현재부터 3일 이내의 유통기한
      final threshold =
      DateTime.now().add(const Duration(days: 3)).toIso8601String();

      return CustomFutureBuilder<List<dynamic>>(
        future: context
            .watch<MyAppState>()
            .supabase
            .from('items')
            .select('*, ...ingredient!inner(*)')
            .lte('expiration_date', threshold)
            .then((value) => value as List<dynamic>),
        builder: (context, snapshot) {
          final groupedData = groupBy(snapshot, (item) {
            final expDate = DateTime.parse(item['expiration_date']);
            return expDate.isBefore(DateTime.now()) ? '만료됨' : '임박';
          });

          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Column(
              children: [
                // 상단 재료 목록 영역
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // 새로고침 로직 추가
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: groupedData.entries.map((entry) {
                            return _buildSection(
                              context: context,
                              headerTitle: entry.key,
                              items: entry.value,
                              backgroundColor: entry.key == '만료됨'
                                  ? Colors.redAccent.withOpacity(0.1)
                                  : Colors.orangeAccent.withOpacity(0.1),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                // 하단 버튼 영역 (재고폐기 / 재고활용)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 재고폐기 처리 로직 추가
                          },
                          child: const Text('재고폐기'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 재고활용 처리 로직 추가
                          },
                          child: const Text('재고활용'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // 냉동실, 냉장실, 미분류, 채소 등 다른 카테고리 처리
      final column = {
        '냉동실': 'place_name',
        '냉장실': 'place_name',
        '(미분류)': 'place_name',
        '채소': 'ingredient.category_name',
        '육류': 'ingredient.category_name',
        '과일': 'ingredient.category_name',
        '유제품': 'ingredient.category_name',
      }[title]!;

      return CustomFutureBuilder<List<dynamic>>(
        future: context
            .watch<MyAppState>()
            .supabase
            .from('items')
            .select('*, ...ingredient!inner(*)')
            .eq(column, title)
            .then((value) => value as List<dynamic>),
        builder: (context, snapshot) {
          final groupedItems = groupBy(
            snapshot,
                (item) => item[{
              'place_name': 'category_name',
              'ingredient.category_name': 'place_name',
            }[column]!],
          );

          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Column(
              children: [
                // 상단 재료 목록 영역
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // 새로고침 로직 추가
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: groupedItems.entries.map((entry) {
                            final groupName = entry.key as String? ?? '(기타)';
                            return _buildSection(
                              context: context,
                              headerTitle: groupName,
                              items: entry.value,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                // 하단 버튼 영역 (재고폐기 / 재고활용)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 재고폐기 처리 로직 추가
                          },
                          child: const Text('재고폐기'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 재고활용 처리 로직 추가
                          },
                          child: const Text('재고활용'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildSection({
    required BuildContext context,
    required String headerTitle,
    required List<dynamic> items,
    Color? backgroundColor,
  }) {
    return _SelectableSection(
      headerTitle: headerTitle,
      items: items,
      backgroundColor: backgroundColor,
    );
  }
}

class _SelectableSection extends StatefulWidget {
  final String headerTitle;
  final List<dynamic> items;
  final Color? backgroundColor;

  const _SelectableSection({
    Key? key,
    required this.headerTitle,
    required this.items,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _SelectableSectionState createState() => _SelectableSectionState();
}

class _SelectableSectionState extends State<_SelectableSection> {
  // 각 아이템의 인덱스를 통해 선택 상태를 관리합니다.
  Set<int> selectedIndices = {};

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
  }

  void _selectAll() {
    setState(() {
      selectedIndices =
          Set.from(List.generate(widget.items.length, (index) => index));
    });
  }

  void _deselectAll() {
    setState(() {
      selectedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    const itemsPerRow = 4;
    final itemWidth = maxWidth / itemsPerRow;

    return Card(
      color: widget.backgroundColor ?? Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // 섹션 헤더: 제목 및 전체 선택/취소 버튼
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.headerTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _selectAll,
                      child: const Text('전체선택'),
                    ),
                    TextButton(
                      onPressed: _deselectAll,
                      child: const Text('전체취소'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // GridView로 품목 나열 (각 카드는 길게 눌러 선택 가능)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: itemsPerRow,
              childAspectRatio: 0.9,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.all(8),
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final isSelected = selectedIndices.contains(index);
                return GestureDetector(
                  onLongPress: () => _toggleSelection(index),
                  child: Stack(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: Container(
                          alignment: Alignment.center,
                          width: itemWidth,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['ingredient_name'] ?? '이름 미지정',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              if (item['expiration_date'] != null)
                                Text(
                                  '유통기한: ${item['expiration_date'].toString().split('T').first}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      ),
                      // 선택된 아이템인 경우 우상단에 체크 아이콘 표시
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
