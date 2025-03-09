import 'package:flutter/material.dart';

class CardGridPage extends StatefulWidget {
  const CardGridPage({super.key});

  @override
  State<CardGridPage> createState() => _CardGridPageState();
}

class _CardGridPageState extends State<CardGridPage> {
  List<bool> items = List.generate(
      12,
      (index) =>
          false); // 4x3 카드 배열, 나중에 container로 변경할 수 있으면 할 것, container 와 card의 차이?

  void navigateToDetailPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          constraints: const BoxConstraints(maxWidth: 400), // 카드 배열 크기
          child: AspectRatio(
            aspectRatio: 4 / 3, // 카드 배열 - 종횡 4:3 배열
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 가로에 4개 배열
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                if (items[index]) {
                  return Card(
                    color: Colors.blue,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () => navigateToDetailPage(index), // 클릭 시 다른 페이지로 이동
                    child: Card(
                      color: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// 다른 페이지 (이미지 + 정보)
class DetailPage extends StatelessWidget {
  final int index;
  const DetailPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item $index'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽 - 이미지 업로드, 추후 이미지 업로드 기능 구현 필요
            Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(
                child: Text(
                  'Click for photo',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 20), // 이미지와 정보 사이 간격

            // 오른쪽 (카드 세로 배열) - 정보, 카드 말고 컨테이너로 바꾸는 것이 크기 조절도 용이하고 코드가 더 직관적일 듯, 추후에 컨테이너로 변경
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCard('Name'),
                  _buildCard('Type'),
                  _buildCard('Storage'),
                  _buildCard('Due'),
                  _buildCard('Vol.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 카드 스타일을 적용한 박스 위젯
  Widget _buildCard(String title) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
