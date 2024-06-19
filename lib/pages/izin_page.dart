import 'dart:convert';
import 'package:absensi/components/list_item.dart';
import 'package:absensi/models/Izin.dart';
import 'package:absensi/pages/tambah_izin_page.dart';
import 'package:absensi/utils/api.dart';
import 'package:badges/badges.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({Key? key}) : super(key: key);

  @override
  _IzinPageState createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  bool isLoading = true;

    var jenisIzin = {
      'i': 'Izin',
      's': 'Sakit',
      'c': 'Cuti',
      's1': 'Sakit Tanpa Surat Dokter',
      'i1': 'Ijin Diluar PP'
    };

  Future<List<Izin>>? _riwayatIzin;
  void getIzin() async => await fetchIzin().then((value){
      setState(() {
        isLoading = false;
        _riwayatIzin = Future<List<Izin>>.value(value);
      });
    }).onError((error, stackTrace){
      setState(() {
        isLoading = false;
      });
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Ada masalah saat menampilkan data",
      );
    });

  @override
  void initState() {
    super.initState();
    getIzin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin'),
        backgroundColor: Colors.blue[900],
      ),
      body: RefreshIndicator(
        onRefresh: () async{
            getIzin();
          },
        child: ListView(
          
          children: [
            isLoading
                ? Center(
                    child: Container(
                      margin: const EdgeInsets.all(50),
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : FutureBuilder<List<Izin>>(
                    future: _riwayatIzin,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Widget> dataAbsen = [];
                        for (var i = 0; i < snapshot.data!.length; i++) {
                          Izin izin = snapshot.data![i];
                          dataAbsen.add(
                            ListItem(
                              title: "${jenisIzin[izin.jenisIzin]}",
                              subTitle: "${izin.tanggalIzin}",
                              onTap: () {
                                
                              },
                              // badge: Badge(
                              //     toAnimate: false,
                              //     shape: BadgeShape.square,
                              //     badgeColor:
                              //         (izin.status != "pending")
                              //             ? (izin.status == "reject")
                              //                 ? Colors.red
                              //                 : Colors.green
                              //             : Colors.orange,
                              //     borderRadius: BorderRadius.circular(8),
                              //     badgeContent: Text("${izin.status}",
                              //         style: const TextStyle(color: Colors.white)),
                              //   ),
                              ));
                        }
                        if (dataAbsen.isEmpty) {
                          dataAbsen.add(const Center(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Tidak ada data'),
                            ),
                          ));
                        }
                        return Column(
                          children: dataAbsen,
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(50),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TambahIzinPage(),
          ));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[900],
      ),
    );
  }
}
