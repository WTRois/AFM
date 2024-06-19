import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:absensi/utils/api.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/pages/tanda_tangan_page.dart';
import 'package:absensi/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelesaiKunjunganPage extends StatefulWidget {
  final dataKunjungan;
  const SelesaiKunjunganPage({Key? key, required this.dataKunjungan})
      : super(key: key);

  @override
  _SelesaiKunjunganPageState createState() => _SelesaiKunjunganPageState();
}

class _SelesaiKunjunganPageState extends State<SelesaiKunjunganPage> {
  final _formKey = GlobalKey<FormState>();

  var pilihWaktu = "waktu sekarang";
  var tanggalWaktuController = TextEditingController();
  var namaKunjunganController = new TextEditingController();
  var keteranganController = TextEditingController();
  LocationData? _locationData;
  Uint8List? tandaTangan = null;

  @override
  void initState() {
    super.initState();
    setState(() {
      namaKunjunganController.text = widget.dataKunjungan['nama_kunjungan'];
    });
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyy, HH:mm:ss').format(now);
    setState(() {
      tanggalWaktuController.text = formattedDate;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bukaTandaTangan() async {
    Uint8List result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TandaTanganPage(),
      ),
    );
    if (result != null) {
      setState(() {
        tandaTangan = result;
      });
    }
  }

  simpanData() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    Uri uri = Uri.parse(Network().getUrl() + '/selesai-kunjungan');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    var h = {
      "Content-type": "application/json",
      "Accept": "application/json",
      HttpHeaders.authorizationHeader:
          'Bearer ${localStorage.getString('token')}',
    };
    request.headers.addAll(h);
    var inputFormat = DateFormat('dd/MM/yyyy, HH:mm:ss');
    var inputDate = inputFormat.parse(tanggalWaktuController.text.toString());

    var outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    var outputDate = outputFormat.format(inputDate);
    request.fields['visit_out'] = outputDate.toString();
    request.fields['visit_out_note'] = keteranganController.text.toString();


    if (tandaTangan != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'visit_out_signature', tandaTangan!,
          filename: 'visit_out_signature.jpg'));
    }

    var response = await request.send();

    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);

    var body = json.decode(responseString);
    Utility().closeLoaderDialog(context);
    if (response.statusCode == 200 && body['error'] == null) {
      Navigator.pop(context);
      CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          text: "Berhasil menyimpan data",
        );
      // Utility().showMsg("Berhasil melakukan absen", context);
    } else if(body['error'] != null){
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: body['error'],
        );
    } else {
      Utility().showMsg(body.toString(), context);
    }
  }

  double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    var arr = [
      'waktu sekarang',
      'pilih waktu',
    ];
    List<DropdownMenuItem<String>> dropDownItem = [];

    for (var i = 0; i < arr.length; i++) {
      dropDownItem.add(DropdownMenuItem(
        child: Text(arr[i].toUpperCase()),
        value: arr[i],
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selesai Kunjungan"),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Lokasi kunjungan anda",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                height: 300,
                child: MapboxMap(
                  accessToken:
                      "sk.eyJ1IjoiYmFndXNpbmRyYXlhbmEiLCJhIjoiY2wzbnV5M3hjMGdveDNwbnlobW9yMmh0ZCJ9.1IKlWm2uMd_VCUPnE9yNEA",
                  onMapCreated: (controller) {
                    LatLng latLng = LatLng(
                                checkDouble(widget.dataKunjungan['latitude']),
                                checkDouble(widget.dataKunjungan['longitude']),
                              );
                    Future.delayed(Duration(seconds: 1), () {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: latLng,
                              zoom: 15),
                        ),
                      );

                      controller.addCircle(
                        CircleOptions(
                          geometry: latLng,
                          circleColor: "#3878ff",
                          circleRadius: 6,
                        ),
                      );
                      
                    });
                  },
                  // minMaxZoomPreference: const MinMaxZoomPreference(6.0, 15.0),
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(45.45, 45.45),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Pilih Waktu Selesai Kunjungan",
                    style: TextStyle(fontSize: 16),
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
                  value: pilihWaktu,
                  onChanged: (String? value) {
                    setState(() {
                      pilihWaktu = value!;
                    });
                  },
                ),
              ),
              (pilihWaktu != "waktu sekarang")
                  ? InkWell(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextFormField(
                          controller: tanggalWaktuController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '1/2/3',
                          ),
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            locale: LocaleType.id,
                            currentTime: DateTime.now(), onChanged: (date) {
                          print('change $date in time zone ' +
                              date.timeZoneOffset.inHours.toString());
                        }, onConfirm: (date) {
                          print('confirm $date');
                          var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                          var inputDate = inputFormat.parse(date.toString());

                          var outputFormat = DateFormat('dd/MM/yyyy, HH:mm:ss');
                          var outputDate = outputFormat.format(inputDate);
                          tanggalWaktuController.text = outputDate.toString();
                        });
                      },
                    )
                  : SizedBox(),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Nama Kunjungan",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  controller: namaKunjunganController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan isi nama kunjungan';
                    }
                    return null;
                  },
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Nama ....',
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Keterangan",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  controller: keteranganController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Keterangan ....',
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Tanda Tangan",
                    style: TextStyle(fontSize: 16),
                  )),
              Center(
                child: Container(
                  width: double.infinity,
                  child: tandaTangan != null
                      ? Stack(
                          children: [
                            InkWell(
                              child: Container(
                                color: Colors.grey[300],
                                child:
                                    Center(child: Image.memory(tandaTangan!)),
                              ),
                              onTap: () {
                                bukaTandaTangan();
                              },
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  child: Container(
                                    child: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      tandaTangan = null;
                                    });
                                  },
                                ))
                          ],
                        )
                      : InkWell(
                          child: Container(
                            height: 100,
                            child: Icon(
                              Icons.draw,
                              color: Colors.blueAccent,
                            ),
                          ),
                          onTap: () {
                            bukaTandaTangan();
                          },
                        ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      primary: Colors.blue[900] // NEW
                      ),
                  child: Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      simpanData();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
