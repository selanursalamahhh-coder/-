class Member {
  int? id;
  String nama;
  String ktp;
  String alamat;
  String telepon;
  String email;

  Member({
    this.id,
    required this.nama,
    required this.ktp,
    required this.alamat,
    required this.telepon,
    required this.email,
  });

  factory Member.fromMap(Map<String, dynamic> map) => Member(
    id: map['id'],
    nama: map['nama'],
    ktp: map['ktp'],
    alamat: map['alamat'],
    telepon: map['telepon'],
    email: map['email'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'ktp': ktp,
    'alamat': alamat,
    'telepon': telepon,
    'email': email,
  };
}
