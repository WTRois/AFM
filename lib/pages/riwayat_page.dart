import 'dart:convert';
import 'package:absensi/components/list_item.dart';
import 'package:absensi/models/RiwayatAbsensi.dart';
import 'package:absensi/pages/detail_kunjungan_page.dart';
import 'package:absensi/pages/detail_riwayat_absensi_page.dart';
import 'package:absensi/pages/login_page.dart';
import 'package:absensi/utils/api.dart';
import 'package:badges/badges.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage>
    with TickerProviderStateMixin {
  String title = "Absensi";
  late TabController _tabController;

  Future<List<RiwayatAbsensi>>? _riwayatAbsen;
  void getAbsensi() async {
    await fetchRiwayatAbsensi().then((value) {
      setState(() {
        _riwayatAbsen = Future<List<RiwayatAbsensi>>.value(value);
      });
    }).onError((error, stackTrace) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Ada masalah saat menampilkan data",
      );
    });
  }

  Future<List<dynamic>>? _riwayatKunjungan;
  void getKunjungan() async {
    var res = await Network().getData('/riwayat-kunjungan');
    var body = json.decode(res.body);

    if (body != null && body['data'] != null) {
      setState(() {
        _riwayatKunjungan = Future<List<dynamic>>.value(body['data']);
      });
    } else {
      print(body);
    }
  }

  Future<List<dynamic>>? _riwayatReimbursement;
  void getReimbursement() async {
    var res = await Network().getData('/riwayat-reimbursement');
    var body = json.decode(res.body);

    if (body != null && body['data'] != null) {
      setState(() {
        _riwayatReimbursement = Future<List<dynamic>>.value(body['data']);
      });
    } else {
      print(body);
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    getAbsensi();
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        getAbsensi();
        setState(() {
          title = "Absensi";
        });
      }
      if (_tabController.index == 1) {
        getKunjungan();
        setState(() {
          title = "Kunjungan";
        });
      }
      if (_tabController.index == 2) {
        getReimbursement();
        setState(() {
          title = "Reimbursement";
        });
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.watch_later)),
            Tab(icon: Icon(Icons.where_to_vote)),
            Tab(icon: Icon(Icons.receipt)),
          ],
        ),
        title: Text('Riwayat ' + title),
        backgroundColor: Colors.blue[900],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: FutureBuilder<List<RiwayatAbsensi>>(
                  future: _riwayatAbsen,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> dataAbsen = [];
                      for (var i = 0; i < snapshot.data!.length; i++) {
                        var riwayatAbsensi = snapshot.data![i];
                        dataAbsen.add(ListItem(
                          title: "${riwayatAbsensi.tanggalAbsen}",
                          subTitle:
                              "${riwayatAbsensi.jenisAbsen}  : ${riwayatAbsensi.waktuAbsen}",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetailRiwayatAbsensiPage(
                                          id: riwayatAbsensi.id)),
                            );
                          },
                          badge: (riwayatAbsensi.status != "due")
                              ? Badge(
                                  toAnimate: false,
                                  shape: BadgeShape.square,
                                  badgeColor:
                                      (riwayatAbsensi.status != "pending")
                                          ? (riwayatAbsensi.status == "reject")
                                              ? Colors.red
                                              : Colors.green
                                          : Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                  badgeContent: Text("${riwayatAbsensi.status}",
                                      style: const TextStyle(color: Colors.white)),
                                )
                              : SizedBox(),
                        ));
                      }
                      return ListView(
                        children: dataAbsen,
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [CircularProgressIndicator()],
                      ),
                    );
                  },
                ),
              ),
              onRefresh: () async {
                getAbsensi();
              }),
          RefreshIndicator(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: FutureBuilder<List<dynamic>>(
                  future: _riwayatKunjungan,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> data = [];
                      for (var i = 0; i < snapshot.data!.length; i++) {
                        data.add(ListItem(
                            title: snapshot.data![i]['nama_kunjungan'],
                            subTitle:
                                "Visit In : ${snapshot.data![i]['visit_in']}, Visit Out : ${snapshot.data![i]['visit_out']}",
                            onTap: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => DetailKunjunganPage(
                                        id: snapshot.data![i]['id'])),
                              );
                            }));
                      }
                      return ListView(
                        children: data,
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [CircularProgressIndicator()],
                      ),
                    );
                  },
                ),
              ),
              onRefresh: () async {
                getKunjungan();
              }),
          RefreshIndicator(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: FutureBuilder<List<dynamic>>(
                  future: _riwayatReimbursement,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> data = [];
                      for (var i = 0; i < snapshot.data!.length; i++) {
                        data.add(ListItem(
                            title: snapshot.data![i]['reimbursement_category']
                                ['category_name'],
                            subTitle: "Tanggal : " +
                                snapshot.data![i]['reimbursement_date']
                                    .toString() +
                                ", Nilai : " +
                                snapshot.data![i]['reimbursement_amount']
                                    .toString(),
                            onTap: () {}));
                      }
                      return ListView(
                        children: data,
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [CircularProgressIndicator()],
                      ),
                    );
                  },
                ),
              ),
              onRefresh: () async {
                getReimbursement();
              }),
        ],
      ),
    );
  }
}
