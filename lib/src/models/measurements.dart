// measurements.dart
// Model class for measurements.

class Measurement {
  final int id;
  final int customerId;
  final int itemTypeId;
  final String? length;
  final String? shoulder;
  final String? slLoose;
  final String? armHole;
  final String? chest;
  final String? hip;
  final String? point;
  final String? seat;
  final String? fNeck;
  final String? bNeck;
  final String? bottomLength;
  final String? bottomWaist;
  final String? bottom;
  final String createdAt;
  final String lastModified;

  Measurement({
    required this.id,
    required this.customerId,
    required this.itemTypeId,
    this.length,
    this.shoulder,
    this.slLoose,
    this.armHole,
    this.chest,
    this.hip,
    this.point,
    this.seat,
    this.fNeck,
    this.bNeck,
    this.bottomLength,
    this.bottomWaist,
    this.bottom,
    required this.createdAt,
    required this.lastModified,
  });

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: int.tryParse(map['id'].toString()) ?? 0,
      customerId: int.tryParse(map['customerId'].toString()) ?? 0,
      itemTypeId: int.tryParse(map['itemTypeId'].toString()) ?? 1,
      length: map['length'],
      shoulder: map['shoulder'],
      slLoose: map['slLoose'],
      armHole: map['armHole'],
      chest: map['chest'],
      hip: map['hip'],
      point: map['point'],
      seat: map['seat'],
      fNeck: map['fNeck'],
      bNeck: map['bNeck'],
      bottomLength: map['bottomLength'],
      bottomWaist: map['bottomWaist'],
      bottom: map['bottom'],
      createdAt: map['createdAt'] ?? '',
      lastModified: map['lastModified'] ?? map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'itemTypeId': itemTypeId,
      'length': length,
      'shoulder': shoulder,
      'slLoose': slLoose,
      'armHole': armHole,
      'chest': chest,
      'hip': hip,
      'point': point,
      'seat': seat,
      'fNeck': fNeck,
      'bNeck': bNeck,
      'bottomLength': bottomLength,
      'bottomWaist': bottomWaist,
      'bottom': bottom,
      'createdAt': createdAt,
      'lastModified': lastModified,
    };
  }

  List<String> toSheetRow(List<String> headers) {
    return headers.map((h) => toMap()[h]?.toString() ?? '').toList();
  }

  static List<String> sheetHeaders = [
    'id',
    'customerId',
    'itemTypeId',
    'length',
    'shoulder',
    'slLoose',
    'armHole',
    'chest',
    'hip',
    'point',
    'seat',
    'fNeck',
    'bNeck',
    'bottomLength',
    'bottomWaist',
    'bottom',
    'createdAt',
    'lastModified',
  ];
}
