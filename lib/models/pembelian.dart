import 'dart:convert';

class Pembelian {
  final int? id;
  final String tanggal;
  final String namaVendor;
  final String metodePembayaran;
  final List<PembelianItem> items;
  final int total;

  Pembelian({
    this.id,
    required this.tanggal,
    required this.namaVendor,
    required this.metodePembayaran,
    required this.items,
    required this.total,
  });

  factory Pembelian.fromMap(Map<String, dynamic> map) => Pembelian(
    id: map['id'],
    tanggal: map['tanggal'],
    namaVendor: map['namaVendor'],
    metodePembayaran: map['metodePembayaran'] ?? 'Tunai',
    items: PembelianItem.decodeList(map['items']),
    total: map['total'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tanggal': tanggal,
    'namaVendor': namaVendor,
    'metodePembayaran': metodePembayaran,
    'items': PembelianItem.encodeList(items),
    'total': total,
  };
}

class PembelianItem {
  final int barangId;
  final String namaBarang;
  final int qty;
  final int harga;

  PembelianItem({
    required this.barangId,
    required this.namaBarang,
    required this.qty,
    required this.harga,
  });

  factory PembelianItem.fromMap(Map<String, dynamic> map) => PembelianItem(
    barangId: map['barangId'],
    namaBarang: map['namaBarang'],
    qty: map['qty'],
    harga: map['harga'],
  );

  Map<String, dynamic> toMap() => {
    'barangId': barangId,
    'namaBarang': namaBarang,
    'qty': qty,
    'harga': harga,
  };

  static List<PembelianItem> decodeList(String encoded) {
    if (encoded.isEmpty) return [];
    try {
      final List<dynamic> list = List<dynamic>.from(jsonDecode(encoded));
      return list
          .map((e) => PembelianItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<PembelianItem> items) {
    return jsonEncode(items.map((e) => e.toMap()).toList());
  }
}
