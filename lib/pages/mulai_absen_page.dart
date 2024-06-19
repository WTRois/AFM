import 'package:flutter/material.dart';

class MulaiAbsenPage extends StatefulWidget {
  final String absenType;
  final dynamic lokasis;
  final dynamic dataAbsensi;
  const MulaiAbsenPage({ Key? key, required this.absenType, required this.lokasis, required this.dataAbsensi }) : super(key: key);

  @override
  State<MulaiAbsenPage> createState() => _MulaiAbsenPageState();
}

class _MulaiAbsenPageState extends State<MulaiAbsenPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}