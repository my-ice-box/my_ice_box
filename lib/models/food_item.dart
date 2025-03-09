class FoodItem {
  final String id;
  final String name;
  final DateTime expiryDate;
  final String section;
  final int quantity; // 추가 필드 예시 (옵션)

  FoodItem({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.section,
    this.quantity = 1, // 기본값 설정
  });

  // JSON 데이터를 FoodItem 객체로 변환 (Supabase에서 데이터 가져올 때 사용)
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      section: json['section'] as String,
      quantity: json['quantity'] as int? ?? 1, // null이면 1로 기본값
    );
  }

  // FoodItem 객체를 JSON으로 변환 (Supabase에 저장할 때 사용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expiry_date': expiryDate.toIso8601String(),
      'section': section,
      'quantity': quantity,
    };
  }

  // 유통기한 D-day 계산 기능 (옵션)
  int get dDay {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  // 복사 기능 (수정 시 유용)
  FoodItem copyWith({
    String? id,
    String? name,
    DateTime? expiryDate,
    String? section,
    int? quantity,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      expiryDate: expiryDate ?? this.expiryDate,
      section: section ?? this.section,
      quantity: quantity ?? this.quantity,
    );
  }
}