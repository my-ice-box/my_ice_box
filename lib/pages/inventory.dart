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
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Column(
              children: [
                // 재료 목록 영역: _ExpirationSection 사용 (하나의 컨테이너로 통합)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // 새로고침 로직 추가
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _ExpirationSection(
                          items: snapshot,
                          backgroundColor: Colors.orangeAccent.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // 기타 카테고리 처리 (냉동실, 냉장실, 미분류, 채소 등)
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
                            return _SelectableSection(
                              headerTitle: groupName,
                              items: entry.value,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
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

//////////////////////////////////////////
/// _ExpirationSection : 재고 처리 탭용  ///
//////////////////////////////////////////
class _ExpirationSection extends StatefulWidget {
  final List<dynamic> items;
  final Color? backgroundColor;

  const _ExpirationSection({
    Key? key,
    required this.items,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _ExpirationSectionState createState() => _ExpirationSectionState();
}

class _ExpirationSectionState extends State<_ExpirationSection> {
  // 유효 품목과 만료 품목 각각의 선택 상태를 관리합니다.
  Set<int> selectedValidIndices = {};
  Set<int> selectedExpiredIndices = {};

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    const itemsPerRow = 4;
    final itemWidth = maxWidth / itemsPerRow;

    // 유통기한(만료일) 오름차순 정렬
    List<dynamic> sortedItems = List.from(widget.items);
    sortedItems.sort((a, b) {
      DateTime aDate = DateTime.parse(a['expiration_date']);
      DateTime bDate = DateTime.parse(b['expiration_date']);
      return aDate.compareTo(bDate);
    });

    final now = DateTime.now();
    // 유효한 품목: 아직 만료되지 않은 항목 (현재 시각과 같거나 이후)
    final validItems = sortedItems.where((item) {
      final expDate = DateTime.parse(item['expiration_date']);
      return !expDate.isBefore(now);
    }).toList();
    // 만료된 품목: 현재 시각보다 이전인 항목
    final expiredItems = sortedItems.where((item) {
      final expDate = DateTime.parse(item['expiration_date']);
      return expDate.isBefore(now);
    }).toList();

    return Card(
      color: widget.backgroundColor ?? Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 헤더: "유효기한 유의품목"
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(
              '유효기한 유의품목',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // 유효 품목 Grid
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: validItems.isNotEmpty
                ? GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: itemsPerRow,
              childAspectRatio: 0.9,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(validItems.length, (index) {
                final item = validItems[index];
                final isSelected = selectedValidIndices.contains(index);
                // 디데이 계산 (유효기한)
                final expirationDate = DateTime.parse(item['expiration_date']);
                final diffDays = expirationDate.difference(now).inDays;
                final dDayText = diffDays > 0 ? 'D-$diffDays' : 'D-Day';
                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      if (isSelected) {
                        selectedValidIndices.remove(index);
                      } else {
                        selectedValidIndices.add(index);
                      }
                    });
                  },
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
                                  dDayText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      ),
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
            )
                : Container(
              padding: const EdgeInsets.all(8),
              child: Center(child: Text("유효한 품목이 없습니다.")),
            ),
          ),
          // 만료된 품목이 있을 경우 구분선과 "유효기한 만료" 레이블, 만료 품목 Grid 표시
          if (expiredItems.isNotEmpty) ...[
            Divider(thickness: 1, color: Colors.grey),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              child: Text(
                '유효기한 만료',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: itemsPerRow,
                childAspectRatio: 0.9,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(expiredItems.length, (index) {
                  final item = expiredItems[index];
                  final isSelected = selectedExpiredIndices.contains(index);
                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (isSelected) {
                          selectedExpiredIndices.remove(index);
                        } else {
                          selectedExpiredIndices.add(index);
                        }
                      });
                    },
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
                                // 기한이 지난 항목은 "기한만료"를 빨간색으로 표시
                                Text(
                                  '기한만료',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
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
        ],
      ),
    );
  }
}

//////////////////////////////////////////////
/// _SelectableSection : 기타 카테고리용  ///
//////////////////////////////////////////////
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

    bool allSelected =
        widget.items.isNotEmpty && selectedIndices.length == widget.items.length;

    return Card(
      color: widget.backgroundColor ?? Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // 헤더: 제목 및 전체 선택/취소 버튼
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
          // GridView로 품목 나열 (개별 선택 가능)
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
                                      ?.copyWith(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      ),
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
