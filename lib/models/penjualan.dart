import 'dart:convert';

class Penjualan {
  final int? id;
  final String tanggal;
  final String namaPelanggan;
  final List<PenjualanItem> items;
  final int total;

  Penjualan({
    this.id,
    required this.tanggal,
    required this.namaPelanggan,
    required this.items,
    required this.total,
  });

  factory Penjualan.fromMap(Map<String, dynamic> map) => Penjualan(
    id: map['id'],
    tanggal: map['tanggal'],
    namaPelanggan: map['namaPelanggan'],
    items: PenjualanItem.decodeList(map['items']),
    total: map['total'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tanggal': tanggal,
    'namaPelanggan': namaPelanggan,
    'items': PenjualanItem.encodeList(items),
    'total': total,
  };
}

class PenjualanItem {
  final int barangId;
  final String namaBarang;
  final int qty;
  final int harga;

  PenjualanItem({
    required this.barangId,
    required this.namaBarang,
    required this.qty,
    required this.harga,
  });

  factory PenjualanItem.fromMap(Map<String, dynamic> map) => PenjualanItem(
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

  static List<PenjualanItem> decodeList(String encoded) {
    if (encoded.isEmpty) return [];
    try {
      final List<dynamic> list = List<dynamic>.from(jsonDecode(encoded));
      return list
          .map((e) => PenjualanItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<PenjualanItem> items) {
    return jsonEncode(items.map((e) => e.toMap()).toList());
  }
}
