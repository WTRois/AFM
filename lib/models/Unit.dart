import 'dart:convert';

import 'package:absensi/utils/api.dart';

class Unit {
  final int id;
  final String kodeUnit;
  final String namaUnit;
  final String? keterangan;

  const Unit({
    required this.id,
    required this.kodeUnit,
    required this.namaUnit,
    this.keterangan,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
        id: json['id'],
        kodeUnit: json['kode_unit'],
        namaUnit: json['nama_unit'],
        keterangan: json['keterangan']);
  }
}

Future<Unit> fetchUnit() async {
  var res = await Network().getData('/unit');
  var json = jsonDecode(res.body);
  if (res.statusCode == 200 && json['data'] != null) {
    return Unit.fromJson(json['data']);
  } else {
    throw Exception('Failed to load album');
  }
}
