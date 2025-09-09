// order.dart
// Model class for orders.

class Order {
  final int id;
  final String orderNumber;
  final int customerId;
  final String orderDate;
  final String dueDate;
  final String? location;
  final int? noOfPs;
  final double? totalPrice;
  final String status;
  final int? totalPieces;
  final String createdAt;
  final String lastModified;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.orderDate,
    required this.dueDate,
    this.location,
    this.noOfPs,
    this.totalPrice,
    required this.status,
    this.totalPieces,
    required this.createdAt,
    required this.lastModified,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: int.tryParse(map['id'].toString()) ?? 0,
      orderNumber: map['orderNumber'] ?? '',
      customerId: int.tryParse(map['customerId'].toString()) ?? 0,
      orderDate: map['orderDate'] ?? '',
      dueDate: map['dueDate'] ?? '',
      location: map['location'],
      noOfPs: map['noOfPs'] != null
          ? int.tryParse(map['noOfPs'].toString())
          : null,
      totalPrice: map['totalPrice'] != null
          ? double.tryParse(map['totalPrice'].toString())
          : null,
      status: map['status'] ?? '',
      totalPieces: map['totalPieces'] != null
          ? int.tryParse(map['totalPieces'].toString())
          : null,
      createdAt: map['createdAt'] ?? '',
      lastModified: map['lastModified'] ?? map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'orderDate': orderDate,
      'dueDate': dueDate,
      'location': location,
      'noOfPs': noOfPs,
      'totalPrice': totalPrice,
      'status': status,
      'totalPieces': totalPieces,
      'createdAt': createdAt,
      'lastModified': lastModified,
    };
  }

  List<String> toSheetRow(List<String> headers) {
    return headers.map((h) => toMap()[h]?.toString() ?? '').toList();
  }

  static List<String> sheetHeaders = [
    'id',
    'orderNumber',
    'customerId',
    'orderDate',
    'dueDate',
    'location',
    'noOfPs',
    'totalPrice',
    'status',
    'totalPieces',
    'createdAt',
    'lastModified',
  ];
}

class OrderDetail {
  final int id;
  final int orderId;
  final int itemTypeId;
  final String? itemDetail;
  final int? noOfPs;
  final double? price;
  final String? measurementType;
  final String createdAt;
  final String lastModified;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.itemTypeId,
    this.itemDetail,
    this.noOfPs,
    this.price,
    this.measurementType,
    required this.createdAt,
    required this.lastModified,
  });

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: int.tryParse(map['id'].toString()) ?? 0,
      orderId: int.tryParse(map['orderId'].toString()) ?? 0,
      itemTypeId: int.tryParse(map['itemTypeId'].toString()) ?? 0,
      itemDetail: map['itemDetail'],
      noOfPs: map['noOfPs'] != null
          ? int.tryParse(map['noOfPs'].toString())
          : null,
      price: map['price'] != null
          ? double.tryParse(map['price'].toString())
          : null,
      measurementType: map['measurementType'],
      createdAt: map['createdAt'] ?? '',
      lastModified: map['lastModified'] ?? map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'itemTypeId': itemTypeId,
      'itemDetail': itemDetail,
      'noOfPs': noOfPs,
      'price': price,
      'measurementType': measurementType,
      'createdAt': createdAt,
      'lastModified': lastModified,
    };
  }

  List<String> toSheetRow(List<String> headers) {
    return headers.map((h) => toMap()[h]?.toString() ?? '').toList();
  }

  static List<String> sheetHeaders = [
    'id',
    'orderId',
    'itemTypeId',
    'itemDetail',
    'noOfPs',
    'price',
    'measurementType',
    'createdAt',
    'lastModified',
  ];
}
