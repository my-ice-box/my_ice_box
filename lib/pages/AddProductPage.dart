import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_ice_box/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String? productName;
  String? productCategory; // Supabase의 category 테이블의 category_name
  String? productPlace; // 저장 장소 (items 테이블의 place_name)
  DateTime? expirationDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("제품 추가")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 제품 이름 입력 필드 (한글 입력 지원)
              TextFormField(
                decoration: const InputDecoration(labelText: '제품 이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제품 이름을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  productName = value;
                },
              ),
              const SizedBox(height: 15),
              // 저장 장소 선택 (ToggleButtons 방식, 고정 옵션)
              const Text('저장 장소 선택'),
              PlaceSelector(
                onPlaceSelected: (selectedPlace) {
                  productPlace = selectedPlace;
                },
              ),
              const SizedBox(height: 15),
              // 드롭다운 방식의 카테고리 선택 (Supabase의 category 테이블 사용)
              CategorySelector(
                onCategorySelected: (selectedCategory) {
                  productCategory = selectedCategory;
                },
              ),
              const SizedBox(height: 15),
              // 유통기한 선택
              ListTile(
                title: Text(expirationDate == null
                    ? "유통기한 선택"
                    : "유통기한: ${expirationDate!.toLocal().toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: expirationDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      expirationDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              // 제품 추가 버튼
              ElevatedButton(
                child: const Text("제품 추가"),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (productPlace == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("저장 장소를 선택해주세요")),
                      );
                      return;
                    }
                    if (productCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("카테고리를 선택해주세요")),
                      );
                      return;
                    }
                    _formKey.currentState!.save();

                    // Supabase를 통한 제품 추가 로직
                    final myAppState =
                    Provider.of<MyAppState>(context, listen: false);
                    final response = await myAppState.supabase.from('items').insert({
                      'ingredient_name': productName,
                      'ingredient': {'category_name': productCategory},
                      'place_name': productPlace,
                      'expiration_date': expirationDate?.toIso8601String(),
                    });
                    // insert() 결과를 바로 받아오므로, 에러 발생 시 try-catch로 감싸는 것도 고려 가능
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("제품이 추가되었습니다!")),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 저장 장소 선택을 ToggleButtons로 구현한 위젯 (고정 옵션: 냉동, 냉장, (미분류))
class PlaceSelector extends StatefulWidget {
  final Function(String) onPlaceSelected;
  const PlaceSelector({Key? key, required this.onPlaceSelected})
      : super(key: key);

  @override
  State<PlaceSelector> createState() => _PlaceSelectorState();
}

class _PlaceSelectorState extends State<PlaceSelector> {
  final List<String> places = ['냉동', '냉장', '(미분류)'];
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isSelected =
    List<bool>.generate(places.length, (index) => index == selectedIndex);
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (index) {
        setState(() {
          selectedIndex = index;
        });
        widget.onPlaceSelected(places[index]);
      },
      children: places
          .map((place) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(place),
      ))
          .toList(),
    );
  }
}

/// 드롭다운 방식으로 카테고리 선택 기능을 제공하는 위젯
class CategorySelector extends StatefulWidget {
  final Function(String) onCategorySelected;
  const CategorySelector({Key? key, required this.onCategorySelected})
      : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  List<String> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final myAppState = Provider.of<MyAppState>(context, listen: false);
    try {
      // 'category' 테이블에서 'category_name' 컬럼 선택
      final response =
      await myAppState.supabase.from('category').select('category_name');
      setState(() {
        categories = List<Map<String, dynamic>>.from(response)
            .map((e) => e['category_name'].toString())
            .toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 불러오기 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: '카테고리 선택',
        border: OutlineInputBorder(),
      ),
      value: selectedCategory,
      items: categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat,
          child: Text(cat),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
        if (value != null) {
          widget.onCategorySelected(value);
        }
      },
    );
  }
}
