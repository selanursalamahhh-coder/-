class Barang {
  int? id;
  String nama;
  String kategori;
  int harga;
  int stok;
  String satuan;
  String? gambarPath;

  Barang({
    this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.satuan,
    this.gambarPath,
  });

  factory Barang.fromMap(Map<String, dynamic> map) => Barang(
    id: map['id'],
    nama: map['nama'],
    kategori: map['kategori'],
    harga: map['harga'],
    stok: map['stok'],
    satuan: map['satuan'],
    gambarPath: map['gambarPath'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'kategori': kategori,
    'harga': harga,
    'stok': stok,
    'satuan': satuan,
    'gambarPath': gambarPath,
  };
}
