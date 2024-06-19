import 'dart:convert';
import 'dart:io';
import 'package:absensi/pages/izin_page.dart';
import 'package:absensi/pages/kalender_jadwal_kerja_page.dart';
import 'package:absensi/pages/login_page.dart';
import 'package:absensi/pages/riwayat_page.dart';
import 'package:absensi/pages/timesheet_page.dart';
import 'package:absensi/pages/ubah_profile_page.dart';
import 'package:absensi/utils/api.dart';
import 'package:absensi/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({Key? key}) : super(key: key);

  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  var userJson;
  String? _linkFoto;
  String? token;
  void logout() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove("token");
    //localStorage.remove("user");
    //localStorage.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // void profil() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   String? userString = localStorage.getString('user');
  //   if(userString != null){
  //     setState(() {

  //       userJson = json.decode(userString);
  //       print(userJson);
  //     });
  //   }
  // }

  void profil() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
    var res = await Network().getData('/profil');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      DateTime now = DateTime.now();
      setState(() {
        userJson = body['data'];
        if (userJson['foto'] != null || userJson['foto_user'] != null) {
          _linkFoto = Network().getUrl() +
              "/foto-profile?size=small&time=${now.toString()}";
        }
        userJson['token'] = token;
        localStorage.setString('user', jsonEncode(userJson));
      });
    } else {
      print(body);
    }
    Utility().closeLoaderDialog(context);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      profil();
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
        title: const Text('Akun'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit User',
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => UbahProfilePage()),
              ).then((value) {
                setState(() {
                  // Call setState to refresh the page.
                });
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          profil();
        },
        child: SingleChildScrollView(
            child: Container(
          child: Column(
            children: <Widget>[
              // Card(
              //   child: ListTile(
              //     leading: (_linkFoto != null && token != null)
              //         ? CircleAvatar(
              //             backgroundImage: NetworkImage(_linkFoto!, headers: {
              //               HttpHeaders.authorizationHeader: 'Bearer $token',
              //             }),
              //           )
              //         : CircleAvatar(
              //             backgroundColor: Colors.blue,
              //             child: Text(
              //                 '${(userJson != null) ? userJson['nama'][0] : '..'}'),
              //           ),
              //     title: Text('${(userJson != null) ? userJson['nama'] : ''}'),
              //     onTap: () {
              //       Navigator.push(
              //         context,
              //         new MaterialPageRoute(
              //             builder: (context) => UbahProfilePage()),
              //       ).then((value) {
              //         setState(() {
              //           // Call setState to refresh the page.
              //         });
              //       });
              //     },
              //   ),
              // ),
              (userJson != null && userJson['_type'] == 'karyawan')
                  ? Card(
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: (_linkFoto != null && token != null)
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        NetworkImage(_linkFoto!, headers: {
                                      HttpHeaders.authorizationHeader:
                                          'Bearer $token',
                                    }),
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      '${(userJson != null) ? userJson['nama'][0] : '..'}',
                                      style: TextStyle(fontSize: 50),
                                    ),
                                  ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                                '${(userJson != null) ? userJson['nama'] : ''}',
                                style: TextStyle(fontSize: 24)),
                            Text(
                                '${(userJson != null) ? userJson['email'] : ''}'),
                          ],
                        ),
                        (userJson != null &&
                                userJson['jabatan'] != null &&
                                userJson['jabatan']['operator'] == 1)
                            ? Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                            "${(userJson != null) ? userJson['total_rit'] : '000'}",
                                            style: TextStyle(fontSize: 20)),
                                        Text("RIT")
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                            "${(userJson != null) ? userJson['total_hm'] : '000'}",
                                            style: TextStyle(fontSize: 20)),
                                        Text("HM")
                                      ],
                                    )
                                    // Column(
                                    //   children: [
                                    //     Text(
                                    //         "${(userJson != null) ? userJson['total_jam_kerja_bulan_ini'] : '00'} Jam",
                                    //         style: TextStyle(fontSize: 20)),
                                    //     Text("Jam Kerja")
                                    //   ],
                                    // ),
                                    // Column(
                                    //   children: [
                                    //     Text(
                                    //         "Rp. ${(userJson != null) ? userJson['total_premi_bulan_ini'] : '000'}",
                                    //         style: TextStyle(fontSize: 20)),
                                    //     Text("Premi")
                                    //   ],
                                    // )
                                  ],
                                ),
                              )
                            : SizedBox(height: 40)
                      ]),
                    )
                  : SizedBox(),
              (userJson != null && userJson['_type'] == 'karyawan')
                  ? Card(
                      child: ListTile(
                        leading: const Icon(Icons.timelapse),
                        title: Text('Riwayat'),
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => RiwayatPage()),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
              (userJson != null && userJson['_type'] == 'karyawan')
                  ? Card(
                      child: ListTile(
                        leading: const Icon(Icons.receipt),
                        title: Text('Timesheet'),
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => TimesheetPage()),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
              (userJson != null && userJson['_type'] == 'karyawan')
                  ? Card(
                      child: ListTile(
                        leading: const Icon(Icons.mail),
                        title: Text('Izin'),
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => IzinPage()),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
              (userJson != null && userJson['_type'] == 'karyawan')
                  ? Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: Text('Jadwal Kerja'),
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    KalenderJadwalKerjaPage()),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    logout();
                  },
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
