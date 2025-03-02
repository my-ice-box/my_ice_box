import 'package:flutter/material.dart';
import '../models/food_item.dart';

class SectionScreen extends StatefulWidget {
  final String sectionName;

  const SectionScreen({super.key, required this.sectionName});

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  List<FoodItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sectionName} 관리'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) => _buildItemCard(_items[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemCard(FoodItem item) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('유통기한: ${item.expiryDate.toString().substring(0, 10)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, item),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteItem(item.id),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem(FoodItem newItem) {
    setState(() {
      _items.add(newItem);
    });
  }

  void _updateItem(FoodItem updatedItem) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
      }
    });
  }

  void _deleteItem(String itemId) {
    setState(() {
      _items.removeWhere((item) => item.id == itemId);
    });
  }

  Future<void> _showAddDialog(BuildContext context) async {
    _nameController.clear();
    _expiryController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 아이템 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _expiryController,
              decoration: const InputDecoration(
                labelText: '유통기한 (YYYY-MM-DD)',
                hintText: '2024-03-30',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final newItem = FoodItem(
        id: DateTime.now().toString(),
        name: _nameController.text,
        expiryDate: DateTime.parse(_expiryController.text),
        section: widget.sectionName,
      );
      _addItem(newItem);
    }
  }

  Future<void> _showEditDialog(BuildContext context, FoodItem item) async {
    _nameController.text = item.name;
    _expiryController.text = item.expiryDate.toIso8601String().substring(0, 10);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아이템 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _expiryController,
              decoration: const InputDecoration(
                labelText: '유통기한 (YYYY-MM-DD)',
                hintText: '2024-03-30',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final updatedItem = item.copyWith(
        name: _nameController.text,
        expiryDate: DateTime.parse(_expiryController.text),
      );
      _updateItem(updatedItem);
    }
  }
}