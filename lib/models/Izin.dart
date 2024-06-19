import 'dart:convert';

import 'package:absensi/models/User.dart';
import 'package:absensi/utils/api.dart';

class Izin {
  final int id;
  final String tanggalIzin;
  final String jenisIzin;
  final String keterangan;
  final String? lampiran;
  final String status;
  final User? user;
  final String? tanggapanVerifikator;

  const Izin({
    required this.id,
    required this.tanggalIzin,
    required this.jenisIzin,
    required this.keterangan,
    this.lampiran,
    required this.status,
    this.user,
    this.tanggapanVerifikator,
  });

  factory Izin.fromJson(Map<String, dynamic> json) {
    return Izin(
        id: json['id'],
        tanggalIzin: json['tanggal_izin'],
        jenisIzin: json['jenis_izin'],
        keterangan: json['keterangan'],
        lampiran: json['lampiran'],
        status: json['status'],
        user: json['user'] != null ? User.fromJson(json['user']) : json['user'],
        tanggapanVerifikator: json['tanggapan_verifikator']);
  }
}

Future<List<Izin>> fetchIzin() async {
  var res = await Network().getData('/riwayat-izin');
  var jsonData = jsonDecode(res.body);
  if (res.statusCode == 200 && jsonData['data'] != null) {
    List<Izin> izins = [];
    for (var i = 0; i < jsonData['data'].length; i++) {
      izins.add(Izin.fromJson(jsonData['data'][i]));
    }
    return izins;
  } else {
    throw Exception('Failed to load izin');
  }
}
