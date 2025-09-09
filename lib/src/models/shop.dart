// shop.dart
// Model class for tailoring shops.

class Shop {
  final int id;
  final String name;
  final String location;
  final String phone;
  final String createdAt;
  final String lastModified;

  Shop({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
    required this.createdAt,
    required this.lastModified,
  });

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: map['createdAt'] ?? '',
      lastModified: map['lastModified'] ?? map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'phone': phone,
      'createdAt': createdAt,
      'lastModified': lastModified,
    };
  }

  List<String> toSheetRow(List<String> headers) {
    return headers.map((h) => toMap()[h]?.toString() ?? '').toList();
  }

  static List<String> sheetHeaders = [
    'id',
    'name',
    'location',
    'phone',
    'createdAt',
    'lastModified',
  ];
}
