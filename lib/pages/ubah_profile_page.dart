import 'dart:convert';
import 'dart:io';
import 'package:absensi/main.dart';
import 'package:absensi/utils/api.dart';
import 'package:absensi/utils/utility.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UbahProfilePage extends StatefulWidget {
  const UbahProfilePage({Key? key}) : super(key: key);

  @override
  _UbahProfilePageState createState() => _UbahProfilePageState();
}

class _UbahProfilePageState extends State<UbahProfilePage> {
  final _formKey = GlobalKey<FormState>();
  XFile? fotoProfile = null;
  var namaController = TextEditingController();
  var emailController = TextEditingController();
  var nohpController = TextEditingController();
  var passwordController = TextEditingController();
  var userJson;
  String? _linkFoto;
  String? token;

  bool isValidEmail(String string) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(string);
  }

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  pilihGambar() async {
    MyApp.openGaleri = true;
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        fotoProfile = image;
        MyApp.openGaleri = false;
      });
    }
  }

  void profil() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
    var res = await Network().getData('/profil');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      setState(() {
        userJson = body['data'];
        namaController.text = userJson['nama'];
        emailController.text = userJson['email'];
        nohpController.text = userJson['no_hp'];
        DateTime now = DateTime.now();
        if(userJson['foto'] != null || userJson['foto_user'] != null){
          _linkFoto = Network().getUrl() + "/foto-profile?time=${now.toString()}";
        }
        
        localStorage.setString('user', jsonEncode(userJson));
        
      });
    } else {
      print(body);
    }
    Utility().closeLoaderDialog(context);
  }

  simpanData() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    Uri uri = Uri.parse(Network().getUrl() + '/update-profile');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    var h = {
      "Content-type": "application/json",
      "Accept": "application/json",
      HttpHeaders.authorizationHeader:
          'Bearer ${localStorage.getString('token')}',
    };
    request.headers.addAll(h);

    request.fields['nama'] = namaController.text.toString();
    request.fields['email'] = emailController.text.toString();
    request.fields['no_hp'] = nohpController.text.toString();
    request.fields['password_baru'] = passwordController.text.toString();

    if (fotoProfile != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoProfile!.path));
      
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
        title: const Text('Ubah Profile'),
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
                    "Foto Profile",
                    style: TextStyle(fontSize: 16),
                  )),
              Center(
                child: Container(
                  width: double.infinity,
                  child: fotoProfile != null
                      ? Stack(
                          children: [
                            InkWell(
                              child: Container(
                                color: Colors.grey[300],
                                child: Center(
                                    child: Image.file(File(fotoProfile!.path))),
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
                                      fotoProfile = null;
                                    });
                                  },
                                ))
                          ],
                        )
                      : InkWell(
                          child: (_linkFoto != null && token != null)
                              ? Image.network(_linkFoto!, headers: {
                                  HttpHeaders.authorizationHeader:
                                      'Bearer $token',
                                })
                              : Container(
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
                  child: Text(
                    "Nama",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  controller: namaController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan isi nama';
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
                    "Email",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan isi email';
                    } else {
                      if (!isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Email ....',
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "No HP",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: nohpController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan isi no hp';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'No HP',
                    
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Password Baru",
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                child: TextFormField(
                  
                  controller: passwordController,
                  obscureText: _secureText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _secureText ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _secureText = !_secureText;
                        });
                      },
                    ),
                  ),
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
