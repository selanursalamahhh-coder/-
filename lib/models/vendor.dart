class Vendor {
  final int? id;
  final String nama;
  final String alamat;
  final String telepon;
  final String email;

  Vendor({
    this.id,
    required this.nama,
    required this.alamat,
    required this.telepon,
    required this.email,
  });

  factory Vendor.fromMap(Map<String, dynamic> map) => Vendor(
    id: map['id'],
    nama: map['nama'],
    alamat: map['alamat'],
    telepon: map['telepon'],
    email: map['email'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'alamat': alamat,
    'telepon': telepon,
    'email': email,
  };
}
