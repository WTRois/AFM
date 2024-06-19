class Perusahaan {
  final int id;
  final String namaPerusahaan;
  final String alamatPerusahaan;

  const Perusahaan({
    required this.id,
    required this.namaPerusahaan,
    required this.alamatPerusahaan,
  });

  factory Perusahaan.fromJson(Map<String, dynamic> json) {
    return Perusahaan(
        id: json['id'],
        namaPerusahaan: json['nama_perusahaan'],
        alamatPerusahaan: json['alamat_perusahaan']);
  }
}
