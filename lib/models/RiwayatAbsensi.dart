import 'dart:convert';

import 'package:absensi/utils/api.dart';

class RiwayatAbsensi {
  final int id;
  final int absensiId;
  final String jenisAbsen;
  final String? tanggalAbsen;
  final String? waktuAbsen;
  final String statusWaktu;
  final String? keterangan;
  final String? longitude;
  final String? latitude;
  final String statusGps;
  final String? jarakAbsen;
  final String? akurasiGps;
  final String? fotoAbsen;
  final String status;

  const RiwayatAbsensi({
    required this.id,
    required this.absensiId,
    required this.jenisAbsen,
    this.tanggalAbsen,
    this.waktuAbsen,
    required this.statusWaktu,
    this.keterangan,
    this.longitude,
    this.latitude,
    required this.statusGps,
    this.jarakAbsen,
    this.akurasiGps,
    this.fotoAbsen,
    required this.status,
  });

  factory RiwayatAbsensi.fromJson(Map<String, dynamic> json) {
    return RiwayatAbsensi(
        id: json['id'],
        absensiId: json['absensi_id'],
        jenisAbsen: json['jenis_absen'],
        tanggalAbsen: json['tanggal_absen'],
        waktuAbsen: json['waktu_absen'],
        statusWaktu: json['status_waktu'],
        keterangan: json['keterangan'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        statusGps: json['status_gps'],
        jarakAbsen: json['jarak_absen'],
        akurasiGps: json['akurasi_gps'],
        fotoAbsen: json['foto_absen'],
        status: json['status']);
  }
}

Future<List<RiwayatAbsensi>> fetchRiwayatAbsensi() async {
  var res = await Network().getData('/riwayat-absensi');
  var jsonData = json.decode(res.body);
  print(jsonData);
  List<RiwayatAbsensi> listData = [];
  if (res.statusCode == 200 && jsonData['data'] != null) {
    for (var i = 0; i < jsonData['data'].length; i++) {
      var data = jsonData['data'][i];
      listData.add(RiwayatAbsensi.fromJson(data));
    }
    return listData;
  } else {
    throw Exception('Failed to load riwayat absensi');
  }
}

Future<RiwayatAbsensi> fetchDetailRiwayatAbsensi(int id) async {
  var res = await Network().getData("/riwayat-absensi/${id}");
  var jsonData = jsonDecode(res.body);
  if (res.statusCode == 200 && jsonData['data'] != null) {
    return RiwayatAbsensi.fromJson(jsonData['data']);
  } else {
    throw Exception('Failed to load riwayat absensi');
  }
}
