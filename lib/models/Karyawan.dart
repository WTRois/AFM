class Karyawan {
  final int id;
  final String nama;
  final String email;
  final String nohp;
  final String jenisKelamin;
  final String? foto;

  const Karyawan({
    required this.id,
    required this.nama,
    required this.email,
    required this.nohp,
    required this.jenisKelamin,
    this.foto
  });

  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      nohp: json['nohp'],
      jenisKelamin: json['jenis_kelamin'],
      foto: json['foto'],
    );
  }
}