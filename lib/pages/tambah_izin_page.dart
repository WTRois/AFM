import 'dart:convert';
import 'dart:io';
import 'package:absensi/utils/api.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahIzinPage extends StatefulWidget {
  const TambahIzinPage({Key? key}) : super(key: key);

  @override
  _TambahIzinPageState createState() =>
      _TambahIzinPageState();
}

class _TambahIzinPageState extends State<TambahIzinPage> {
  final _formKey = GlobalKey<FormState>();

  var pilihJenis;
  var tanggalWaktuController = TextEditingController();
  var namaIzinController = TextEditingController();
  var jumlahIzinController = TextEditingController();
  var namaPenjualtController = TextEditingController();
  var keteranganController = TextEditingController();
  LocationData? _locationData;
  XFile? lampiran = null;

  List<DropdownMenuItem<String>> dropDownItem = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyy').format(now);
      getCategory();
      setState(() {
        tanggalWaktuController.text = formattedDate;
      });
    });
    
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getCategory() async {
    List<DropdownMenuItem<String>> d = [];
    var jenis = [
      {
        'id': 'i',
        'name':'Izin'
      },
      {
        'id': 's',
        'name':'Sakit'
      },
      {
        'id': 'c',
        'name':'Cuti'
      },
      {
        'id': 's1',
        'name':'Sakit Tanpa Surat Dokter'
      },
      {
        'id': 'i1',
        'name':'Ijin Diluar PP'
      }
    ];
    for (var i = 0; i < jenis.length; i++) {
      d.add(DropdownMenuItem(
        child: Text(jenis[i]['name']!.toUpperCase()),
        value: jenis[i]['id'].toString(),
      ));
    }
    setState(() {
      pilihJenis = jenis[0]['id'].toString();
      dropDownItem = d;
    });
  }

  pilihGambar() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        lampiran = image;
      });
    }
  }

  simpanData() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    Uri uri = Uri.parse(Network().getUrl() + '/tambah-izin');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    var h = {
      "Content-type": "application/json",
      "Accept": "application/json",
      HttpHeaders.authorizationHeader:
          'Bearer ${localStorage.getString('token')}',
    };
    request.headers.addAll(h);

    request.fields['jenis_izin'] = pilihJenis.toString();
    var inputFormat = DateFormat('dd/MM/yyyy');
    var inputDate = inputFormat.parse(tanggalWaktuController.text.toString());

    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(inputDate);
    request.fields['tanggal_izin'] = outputDate.toString();
    request.fields['keterangan'] = keteranganController.text.toString();

    if (lampiran != null) {
      request.files.add(await http.MultipartFile.fromPath('lampiran', lampiran!.path));
      
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

  @override
  Widget build(BuildContext context) {
    
    

    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Izin"),
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
                    "Pilih Jenis Izin",
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
                  value: pilihJenis,
                  onChanged: (String? value) {
                    setState(() {
                      pilihJenis = value!;
                    });
                  },
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Pilih Tanggal",
                    style: TextStyle(fontSize: 16),
                  )),
              InkWell(
                child: Container(
                 
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
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      locale: LocaleType.id,
                      currentTime: DateTime.now(), onChanged: (date) {
                  }, onConfirm: (date) {
                    
                    var inputFormat = DateFormat('yyyy-MM-dd');
                    var inputDate = inputFormat.parse(date.toString());

                    var outputFormat = DateFormat('dd/MM/yyyy');
                    var outputDate = outputFormat.format(inputDate);
                    tanggalWaktuController.text = outputDate.toString();
                  });
                },
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
                    "Lampiran",
                    style: TextStyle(fontSize: 16),
                  )),
              Center(
                child: Container(
                  width: double.infinity,
                  child: lampiran != null
                      ? Stack(
                          children: [
                            InkWell(
                              child: Container(
                                color: Colors.grey[300],
                                child:
                                    Center(child: Image.file(File(lampiran!.path))),
                              ),
                              onTap: () {
                                pilihGambar();
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
                                      lampiran = null;
                                    });
                                  },
                                ))
                          ],
                        )
                      : InkWell(
                          child: Container(
                            height: 100,
                            child: Icon(
                              Icons.image,
                              color: Colors.blueAccent,
                            ),
                          ),
                          onTap: () {
                            pilihGambar();
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
