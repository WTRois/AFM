import 'dart:convert';
import 'package:absensi/pages/izin_page.dart';
import 'package:absensi/pages/login_page.dart';
import 'package:absensi/pages/mulai_kunjungan_page.dart';
import 'package:absensi/pages/selesai_kunjungan_page.dart';
import 'package:absensi/pages/tambah_reimbursement.dart';
import 'package:absensi/pages/camera_screen_page.dart';
import 'package:absensi/pages/timesheet_page.dart';
import 'package:absensi/utils/api.dart';
import 'package:absensi/utils/utility.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class MenuAbsenPage extends StatefulWidget {
  const MenuAbsenPage({Key? key}) : super(key: key);

  @override
  _MenuAbsenPageState createState() => _MenuAbsenPageState();
}

class _MenuAbsenPageState extends State<MenuAbsenPage> {
  var jadwal_absen = null;
  var userJson = null;
  var statusAbsensi = null;
  var units = null;
  List<DropdownMenuItem<String>> dropDownItem = [];
  var pilihUnit;
  var keteranganController = TextEditingController();
  var tanggalWaktuController = TextEditingController();

  void logout() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove("token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void getProfil() async {
    Utility().showLoaderDialog(context);
    try {
      var res = await Network().getData('/profil');
      var body = json.decode(res.body);
      if (res.statusCode == 401) {
        Utility().closeLoaderDialog(context);
        CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: "Ops ada yang salah, silahkan login kembali",
            onConfirmBtnTap: () {
              logout();
            });
      } else if (res.statusCode == 200) {
        if (body['data'] != null) {
          setState(() {
            userJson = body['data'];
            cekAbsensi();
          });
        } else {
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: "Ada masalah saat menampilkan data",
          );
        }
      } else {
        if (body['error'] != null) {
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: body['error'].toString(),
          );
        } else if (body['warning'] != null) {
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.warning,
            text: body['warning'].toString(),
          );
        } else {
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: "Ada masalah saat menampilkan data",
          );
        }
      }
    } catch (e) {
      Utility().closeLoaderDialog(context);
    }
  }

  void cekAbsensi() async {
    var res = await Network().getData('/cek-absensi');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      setState(() {
        statusAbsensi = body['data'];
      });
      Utility().closeLoaderDialog(context);
    } else {
      if (body['error'] != null) {
        Utility().closeLoaderDialog(context);
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: body['error'].toString(),
        );
      } else if (body['warning'] != null) {
        Utility().closeLoaderDialog(context);
        CoolAlert.show(
          context: context,
          type: CoolAlertType.warning,
          text: body['warning'].toString(),
        );
      } else {
        Utility().closeLoaderDialog(context);
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Ada masalah saat menampilkan data",
        );
      }
    }
  }

  void bukaCamera(absenType, lokasis, dataAbsensi, dataTambahan) async {
    if (await ph.Permission.camera.request().isGranted) {
      if (await ph.Permission.locationWhenInUse.request().isGranted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraScreenPage(
                absenType: absenType,
                lokasis: lokasis,
                dataAbsensi: dataAbsensi,
                dataTambahan: dataTambahan),
          ),
        );
      }
    } else {
      final cameraStatus = await ph.Permission.camera.status;
      if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
        Utility().showMsg("aplikasi membutuhkan akses camera", context);
      }
    }
  }

  void bukaAbsen(absen) async {
    Utility().showLoaderDialog(context);
    var res = await Network().getData('/cek-absensi');
    
    try {
      var body = json.decode(res.body);
      if (res.statusCode == 200 && body['data'] != null) {
        
        setState(() {
          statusAbsensi = body['data'];
        });

        if (statusAbsensi != null) {
          if (statusAbsensi[absen]['unit'] != null && statusAbsensi[absen]['unit'].length > 0) {
            setState(() {
              units = statusAbsensi[absen]['unit'];
            });

            List<DropdownMenuItem<String>> d = [];

            for (var i = 0; i < units.length; i++) {
              d.add(DropdownMenuItem(
                child: Text(units[i]['nama_unit'].toUpperCase()),
                value: units[i]['id'].toString(),
              ));
            }
            setState(() {
              pilihUnit = units[0]['id'].toString();
              dropDownItem = d;
            });
          } else {
            setState(() {
              units = null;
            });
          }
          Utility().closeLoaderDialog(context);
          if (statusAbsensi[absen]['status_waktu'] != 'on-time') {
            DateTime now = DateTime.now();
            String formattedDate =
                DateFormat('dd/MM/yyy, HH:mm:ss').format(now);
            setState(() {
              tanggalWaktuController.text = formattedDate;
            });
          }
          if (statusAbsensi[absen]["bisa_absen"]) {
            var _absen = absen.replaceAll("_", "-");
            if (statusAbsensi[absen]['_status'] == 1) {
              
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Ops"),
                    content: Text(statusAbsensi[absen]["keterangan"]),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Batal'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.delayed(Duration.zero, () {
                            if (absen == "mulai_kunjungan") {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MulaiKunjunganPage(),
                                ),
                              );
                            } else if (absen == "selesai_kunjungan") {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SelesaiKunjunganPage(
                                      dataKunjungan: statusAbsensi[absen]
                                          ["data"]),
                                ),
                              );
                            } else {
                              bukaDetailAbsen(
                                  _absen, body['lokasi'], statusAbsensi[absen]);
                            }
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              Future.delayed(Duration.zero, () {
                if (absen == "mulai_kunjungan") {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MulaiKunjunganPage(),
                    ),
                  );
                } else if (absen == "selesai_kunjungan") {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelesaiKunjunganPage(
                          dataKunjungan: statusAbsensi[absen]["data"]),
                    ),
                  );
                } else {
                  bukaDetailAbsen(_absen, body['lokasi'], statusAbsensi[absen]);
                }
              });
            }
          } else {
            Utility()
                .showAlert("Ops", statusAbsensi[absen]["keterangan"], context);
          }
        }
      } else {
        if (body['error'] != null) {
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: body['error'].toString(),
          );
        } else if (body['warning'] != null) {
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.warning,
            text: body['warning'].toString(),
          );
        } else {
          print(body.toString());
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: "Ada masalah saat menampilkan data",
          );
        }
      }
    } catch (e) {
      print(e);
      Utility().closeLoaderDialog(context);
    }
  }

  void bukaDetailAbsen(a, b, c) {
    if (units == null && c['status_waktu'] == 'on-time') {
      bukaCamera(a, b, c, {
        "unit_id": null,
        "tanggal_waktu": null,
        "keterangan_tambahan": null
      });
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Detail Absen"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (units != null)
                  ? Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              "Pilih Unit",
                              textAlign: TextAlign.left,
                            )),
                        Container(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            isExpanded: true,
                            items: dropDownItem,
                            value: pilihUnit,
                            onChanged: (String? value) {
                              setState(() {
                                pilihUnit = value!;
                              });
                            },
                          ),
                        )
                      ],
                    )
                  : SizedBox(),
              Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    "Tanggal & Waktu Absen",
                    textAlign: TextAlign.left,
                  )),
              InkWell(
                child: Container(
                  child: TextFormField(
                    controller: tanggalWaktuController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '01/02/2022',
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                ),
                onTap: () {
                  if (c['status_waktu'] != 'on-time') {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        locale: LocaleType.id,
                        currentTime: DateTime.now(),
                        onChanged: (date) {}, onConfirm: (date) {
                      var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                      var inputDate = inputFormat.parse(date.toString());

                      var outputFormat = DateFormat('dd/MM/yyyy, HH:mm:ss');
                      var outputDate = outputFormat.format(inputDate);
                      tanggalWaktuController.text = outputDate.toString();
                    });
                  }
                },
              ),
              (a == "check_in")
                  ? Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              "Keterangan tambahan",
                              textAlign: TextAlign.left,
                            )),
                        TextField(
                            controller: keteranganController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Keterangan tambahan",
                            ))
                      ],
                    )
                  : SizedBox(),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                var inputFormat = DateFormat('dd/MM/yyyy, HH:mm:ss');
                var inputDate =
                    inputFormat.parse(tanggalWaktuController.text.toString());

                var outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                var outputDate = outputFormat.format(inputDate);
                bukaCamera(a, b, c, {
                  "unit_id": pilihUnit.toString(),
                  "tanggal_waktu": outputDate,
                  "keterangan_tambahan": keteranganController.text
                });
              },
            ),
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getProfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Absensi'),
          backgroundColor: Colors.blue[900],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              getProfil();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 25.h,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/top.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: 100,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: 4,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            bukaAbsen("check_in");
                          },
                          child: const Icon(Icons.input, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                            primary: Colors.blue[900], // <-- Button color
                            onPrimary: Colors.red, // <-- Splash color
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: Text(
                            "Absen Masuk",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            bukaAbsen("check_out");
                          },
                          child: const Icon(Icons.output, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                            primary: Colors.blue[900], // <-- Button color
                            onPrimary: Colors.red, // <-- Splash color
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: Text(
                            "Absen Pulang",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         bukaAbsen("break");
                    //       },
                    //       child:
                    //           const Icon(Icons.restaurant, color: Colors.white),
                    //       style: ElevatedButton.styleFrom(
                    //         shape: const CircleBorder(),
                    //         padding: const EdgeInsets.all(15),
                    //         primary: Colors.blue[900], // <-- Button color
                    //         onPrimary: Colors.red, // <-- Splash color
                    //       ),
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.only(top: 10, bottom: 5),
                    //       child: Text(
                    //         "Mulai Isttirahat",
                    //         style: TextStyle(fontSize: 12),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Column(
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         bukaAbsen("after_break");
                    //       },
                    //       child:
                    //           const Icon(Icons.keyboard, color: Colors.white),
                    //       style: ElevatedButton.styleFrom(
                    //         shape: const CircleBorder(),
                    //         padding: const EdgeInsets.all(15),
                    //         primary: Colors.blue[900], // <-- Button color
                    //         onPrimary: Colors.red, // <-- Splash color
                    //       ),
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.only(top: 10, bottom: 5),
                    //       child: Text(
                    //         "Selesai Istirahat",
                    //         style: TextStyle(fontSize: 12),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Column(
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         bukaAbsen("overtime_in");
                    //       },
                    //       child: const Icon(Icons.update, color: Colors.white),
                    //       style: ElevatedButton.styleFrom(
                    //         shape: const CircleBorder(),
                    //         padding: const EdgeInsets.all(15),
                    //         primary: Colors.blue[900], // <-- Button color
                    //         onPrimary: Colors.red, // <-- Splash color
                    //       ),
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.only(top: 10, bottom: 5),
                    //       child: Text(
                    //         "Mulai Lembur",
                    //         style: TextStyle(fontSize: 12),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Column(
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         bukaAbsen("overtime_out");
                    //       },
                    //       child: const Icon(Icons.restore, color: Colors.white),
                    //       style: ElevatedButton.styleFrom(
                    //         shape: const CircleBorder(),
                    //         padding: const EdgeInsets.all(15),
                    //         primary: Colors.blue[900], // <-- Button color
                    //         onPrimary: Colors.red, // <-- Splash color
                    //       ),
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.only(top: 10, bottom: 5),
                    //       child: Text(
                    //         "Selesai Lembur",
                    //         style: TextStyle(fontSize: 12),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Column(
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         bukaAbsen("mulai_kunjungan");
                    //       },
                    //       child: const Icon(Icons.place, color: Colors.white),
                    //       style: ElevatedButton.styleFrom(
                    //         shape: const CircleBorder(),
                    //         padding: const EdgeInsets.all(15),
                    //         primary: Colors.blue[900], // <-- Button color
                    //         onPrimary: Colors.red, // <-- Splash color
                    //       ),
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.only(top: 10, bottom: 5),
                    //       child: Text(
                    //         "Mulai Kunjungan",
                    //         style: TextStyle(fontSize: 12),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Column(
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         bukaAbsen("selesai_kunjungan");
                    //       },
                    //       child: const Icon(Icons.work, color: Colors.white),
                    //       style: ElevatedButton.styleFrom(
                    //         shape: const CircleBorder(),
                    //         padding: const EdgeInsets.all(15),
                    //         primary: Colors.blue[900], // <-- Button color
                    //         onPrimary: Colors.red, // <-- Splash color
                    //       ),
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.only(top: 10, bottom: 5),
                    //       child: Text(
                    //         "Selesai Kunjungan",
                    //         style: TextStyle(fontSize: 12),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Column(
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         Navigator.of(context).push(MaterialPageRoute(
                    //           builder: (context) => TambahReimbursementPage(),
                    //         ));
                    //       },
                    //       child: const Icon(Icons.receipt, color: Colors.white),
                    //       style: ElevatedButton.styleFrom(
                    //         shape: const CircleBorder(),
                    //         padding: const EdgeInsets.all(15),
                    //         primary: Colors.blue[900], // <-- Button color
                    //         onPrimary: Colors.red, // <-- Splash color
                    //       ),
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.only(top: 10, bottom: 5),
                    //       child: Text(
                    //         "Reimbursement",
                    //         style: TextStyle(fontSize: 12),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TimesheetPage(),
                            ));
                          },
                          child: const Icon(Icons.edit_calendar,
                              color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                            primary: Colors.blue[900], // <-- Button color
                            onPrimary: Colors.red, // <-- Splash color
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: Text(
                            "Timesheet",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => IzinPage(),
                            ));
                          },
                          child: const Icon(Icons.email,
                              color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                            primary: Colors.blue[900], // <-- Button color
                            onPrimary: Colors.red, // <-- Splash color
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: Text(
                            "Izin",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            )));
  }
}
