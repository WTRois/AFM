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

class TambahReimbursementPage extends StatefulWidget {
  const TambahReimbursementPage({Key? key}) : super(key: key);

  @override
  _TambahReimbursementPageState createState() =>
      _TambahReimbursementPageState();
}

class _TambahReimbursementPageState extends State<TambahReimbursementPage> {
  final _formKey = GlobalKey<FormState>();

  var pilihKategori;
  var tanggalWaktuController = TextEditingController();
  var namaReimbursementController = TextEditingController();
  var jumlahReimbursementController = TextEditingController();
  var namaPenjualtController = TextEditingController();
  var keteranganController = TextEditingController();
  LocationData? _locationData;
  XFile? gambarBukti = null;

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
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var res = await Network().getData('/reimbursement-category');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      List<DropdownMenuItem<String>> d = [];
      
      for (var i = 0; i < body['data'].length; i++) {
        d.add(DropdownMenuItem(
          child: Text(body['data'][i]['category_name'].toUpperCase()),
          value: body['data'][i]['id'].toString(),
        ));
      }
      setState(() {
        pilihKategori = body['data'][0]['id'].toString();
        dropDownItem = d;
      });
    } else {
      print(body);
    }
    Utility().closeLoaderDialog(context);
  }

  pilihGambar() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        gambarBukti = image;
      });
    }
  }

  simpanData() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    Uri uri = Uri.parse(Network().getUrl() + '/tambah-reimbursement');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    var h = {
      "Content-type": "application/json",
      "Accept": "application/json",
      HttpHeaders.authorizationHeader:
          'Bearer ${localStorage.getString('token')}',
    };
    request.headers.addAll(h);

    request.fields['reimbursement_name'] = namaReimbursementController.text.toString();
    request.fields['reimbursement_category_id'] = pilihKategori.toString();
    var inputFormat = DateFormat('dd/MM/yyyy');
    var inputDate = inputFormat.parse(tanggalWaktuController.text.toString());

    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(inputDate);
    request.fields['reimbursement_date'] = outputDate.toString();
    
    request.fields['reimbursement_amount'] = jumlahReimbursementController.text.toString();
    request.fields['reimbursement_vendor'] = namaPenjualtController.text.toString();
    request.fields['reimbursement_note'] = keteranganController.text.toString();

    if (gambarBukti != null) {
      request.files.add(await http.MultipartFile.fromPath('reimbursement_prove_picture', gambarBukti!.path));
      
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
        title: const Text("Tambah Reimbursement"),
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
                    "Pilih Ketegori Reimbursement",
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
                  value: pilihKategori,
                  onChanged: (String? value) {
                    setState(() {
                      pilihKategori = value!;
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
                    "Nama Reimbursement",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  controller: namaReimbursementController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan isi nama reimbursement';
                    }
                    return null;
                  },
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
                    "Jumlah Reimbursement",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: jumlahReimbursementController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan isi jumlah reimbursement';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Jumlah ....',
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Nama Penjual",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  controller: namaPenjualtController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan isi nama penjual';
                    }
                    return null;
                  },
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
                    "Foto Bukti",
                    style: TextStyle(fontSize: 16),
                  )),
              Center(
                child: Container(
                  width: double.infinity,
                  child: gambarBukti != null
                      ? Stack(
                          children: [
                            InkWell(
                              child: Container(
                                color: Colors.grey[300],
                                child:
                                    Center(child: Image.file(File(gambarBukti!.path))),
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
                                      gambarBukti = null;
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
