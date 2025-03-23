import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryPage extends StatelessWidget {
  final String title;
  final PostgrestList items;
  final String columnToGroupBy;

  const InventoryPage({
    super.key,
    required this.title,
    required this.items,
    required this.columnToGroupBy,
  });

  @override
  Widget build(BuildContext context) {
    final groupedItems = groupBy(items,
      (item) => item[columnToGroupBy],
    );

    // 상단 재료 목록 영역
    final ingredientLists = Expanded(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: groupedItems.entries.map((entry) {
              return _buildSection(
                context: context,
                headerTitle: entry.key as String,
                items: entry.value,
                backgroundColor: entry.key == '만료됨' ?
                  Colors.redAccent.withValues(alpha: 0.1) :
                  Colors.orangeAccent.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ),
      ),
    );

    // 하단 버튼 영역 (재고폐기 / 재고활용)
    final bottomButtons = Padding(
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
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          ingredientLists,
          bottomButtons,
        ],
      ),
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

class _SelectableSection extends StatefulWidget {
  final String headerTitle;
  final List<dynamic> items;
  final Color? backgroundColor;

  const _SelectableSection({
    required this.headerTitle,
    required this.items,
    this.backgroundColor,
  });

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
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
