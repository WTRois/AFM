import 'dart:convert';
import 'dart:io';
import 'package:cool_alert/cool_alert.dart';
import 'package:absensi/utils/api.dart';
import 'package:absensi/utils/utility.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class CameraScreenPage extends StatefulWidget {
  final String absenType;
  final dynamic lokasis;
  final dynamic dataAbsensi;
  final dynamic dataTambahan;
  const CameraScreenPage(
      {Key? key,
      required this.absenType,
      required this.lokasis,
      required this.dataAbsensi,
      required this.dataTambahan})
      : super(key: key);

  @override
  _CameraScreenPageState createState() => _CameraScreenPageState();
}

class _CameraScreenPageState extends State<CameraScreenPage> {
  List<CameraDescription> cameras = [];

  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  double _jarak = 0;
  loc.Location location = new loc.Location();
  bool _serviceEnabled = false;
  late loc.PermissionStatus _permissionGranted;
  loc.LocationData? _locationData;
  var lokasis;
  bool onspot = false;
  bool gps = true;
  var akurasi;
  var units;

  bool flash = false;
  XFile? image = null;

  var jenisAbsen = {
    "check-in": "Absen Masuk",
    "check-out": "Absen Keluar",
    "break": "Mulai Istirahat",
    "after-break": "Selesai Istirahat",
    "overtime-in": "Mulai Lembur",
    "overtime-out": "Selesai Lembur",
  };

  getLoc() async {
    final serviceStatus = await ph.Permission.locationWhenInUse.serviceStatus;
    bool isGpsOn = serviceStatus == ph.ServiceStatus.enabled;
    if (!isGpsOn) {
      Utility().showMsg("silahkan aftifkan gps anda", context);
      gps = false;
      return;
    }

    final status = await ph.Permission.locationWhenInUse.request();
    if (status == ph.PermissionStatus.granted) {
    } else if (status == ph.PermissionStatus.denied) {
      Utility()
          .showMsg("aplikasi bekerja maksimal ketika gps di aktifkan", context);
      setState(() {
        gps = false;
      });
    } else if (status == ph.PermissionStatus.permanentlyDenied) {
      await ph.openAppSettings();
    }
    if (await ph.Permission.location.isRestricted) {
      Utility().showMsg("tidak bisa mengakses lokasi", context);
      setState(() {
        gps = false;
      });
    }

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Utility().showMsg("tidak bisa mengakses lokasi", context);
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        Utility().showMsg("tidak bisa mengakses lokasi", context);
        return;
      }
    }

    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    await location.getLocation().then((val) {
      _locationData = val;
    });

    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        _locationData = currentLocation;
        akurasi = currentLocation.accuracy.toString();
      });
      if (lokasis != null && lokasis.length > 0) {
        setState(() {
          lokasis!.sort((a, b) {
            var cek = distance(currentLocation.latitude,
                    currentLocation.longitude, a['latitude'], a['longitude'])
                .compareTo(distance(currentLocation.latitude,
                    currentLocation.longitude, b['latitude'], b['longitude']));

            return cek as int;
          });
          double jarak = distance(
              currentLocation.latitude,
              currentLocation.longitude,
              lokasis[0]['latitude'],
              lokasis[0]['longitude']);
          _jarak = jarak;

          if (_jarak.toInt() <= lokasis[0]['radius']) {
            setState(() {
              onspot = true;
            });
          } else {
            setState(() {
              onspot = false;
            });
          }
        });
      }
    });
  }

  rad(x) {
    return x * pi / 180;
  }

  distance(lat1, lon1, lat2, lon2) {
    var R = 6378137; // Radius bumi dalam meter
    var dLat = rad(checkDouble(lat2) - checkDouble(lat1));
    var dLong = rad(checkDouble(lon2) - checkDouble(lon1));
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(rad(checkDouble(lat1))) *
            cos(rad(checkDouble(lat2))) *
            sin(dLong / 2) *
            sin(dLong / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c;
    return d;
  }

  double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value.toDouble();
    }
  }

  void absen(imagePath) {
    var keteranganController = TextEditingController();
    var ketentuan = [];
    if (!onspot) {
      ketentuan.add("di luar lokasi yang ditentukan");
    }
    if (widget.dataAbsensi['status_waktu'] == "late") {
      ketentuan.add("melewati waktu yang ditentukan");
    }
    if (widget.dataAbsensi['status_waktu'] == "too-early") {
      ketentuan.add("sebelum waktu yang ditentukan");
    }
    if (ketentuan.isNotEmpty) {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Absen di luar ketentuan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Anda mencoba absen ${ketentuan.join(",")}.apakah anda ingin melanjutkan absen?"),
                TextField(
                    controller: keteranganController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText:
                          "Berikan keterangan kenapa absen di luar ketentuan",
                    ))
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                  kirimAbsen(imagePath, keteranganController.text);
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
    } else {
      kirimAbsen(imagePath, "");
    }
  }

  kirimAbsen(imagePath, keterangan) async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    Uri uri = Uri.parse(Network().getUrl() + '/absensi/' + widget.absenType);
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    var h = {
      "Content-type": "application/json",
      "Accept": "application/json",
      HttpHeaders.authorizationHeader:
          'Bearer ${localStorage.getString('token')}',
    };
    request.headers.addAll(h);
    request.files
        .add(await http.MultipartFile.fromPath('foto_absen', imagePath));

    if (lokasis != null && lokasis.length > 0) {
      request.fields['lokasi_absen_id'] = lokasis[0]['id'].toString();
    }
    request.fields['jarak_absen'] = _jarak.toString();
    request.fields['akurasi_gps'] = akurasi.toString();
    request.fields['keterangan'] = keterangan.toString();
    request.fields['status_gps'] =
        (gps) ? ((onspot) ? "on-spot" : "out-of-range") : "not-detected";

    //data tambahan
    request.fields['keterangan_tambahan'] =
        widget.dataTambahan['keterangan_tambahan'].toString();
    request.fields['tanggal_waktu'] =
        widget.dataTambahan['tanggal_waktu'].toString();
    if (widget.dataTambahan['unit_id'] != 'null') {
      request.fields['unit_id'] = widget.dataTambahan['unit_id'].toString();
    }

    if (_locationData != null) {
      request.fields['latitude'] = _locationData!.latitude.toString();
      request.fields['longitude'] = _locationData!.longitude.toString();
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
        text: "Berhasil melakukan absen",
      );
      // Utility().showMsg("Berhasil melakukan absen", context);
    } else if (body['error'] != null) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: body['error'],
      );
    } else {
      Utility().showMsg(body.toString(), context);
    }
  }

  void initCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        setState(() {
          _controller = CameraController(
            // Get a specific camera from the list of available cameras.
            cameras.first,
            // Define the resolution to use.
            ResolutionPreset.veryHigh,
          );

          // Next, initialize the controller. This returns a Future.
          if (_controller != null) {
            _initializeControllerFuture = _controller!.initialize();
          }
          // if (!flash && _controller != null) {
          //   try {
          //     _controller!.setFlashMode(FlashMode.auto);
          //   } catch (e) {
          //     print(e);
          //   }
          // }
        });
      }
      getLoc();
    } on CameraException catch (e) {
      Utility().showMsg('Error in fetching the cameras: $e', context);
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(description, ResolutionPreset.max);

    try {
      if (_controller != null) {
        await _controller!.initialize();
        // to notify the widgets that camera has been initialized and now camera preview can be done
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  void getUnit() async {
    Utility().showLoaderDialog(context);

    var res = await Network().getData('/unit-karyawan');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      setState(() {
        units = body['data'];
      });
    } else {
      print(body);
    }
    Utility().closeLoaderDialog(context);
  }

  void _toggleCameraLens() {
    // get current lens direction (front / rear)
    if (_controller != null) {
      final lensDirection = _controller!.description.lensDirection;
      CameraDescription newDescription;
      if (lensDirection == CameraLensDirection.front) {
        newDescription = cameras.firstWhere((description) =>
            description.lensDirection == CameraLensDirection.back);
      } else {
        newDescription = cameras.firstWhere((description) =>
            description.lensDirection == CameraLensDirection.front);
      }

      if (newDescription != null) {
        _initCamera(newDescription);
      } else {
        print('Asked camera not available');
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        lokasis = widget.lokasis;
      });
      initCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    final mediaSize = MediaQuery.of(context).size;
    // final scale = 1 / (_controller!.value.aspectRatio * mediaSize.aspectRatio);

    return Scaffold(
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        title: Text(jenisAbsen[widget.absenType].toString()),
        backgroundColor: Colors.blue[900],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              // alignment: FractionalOffset.center,
              children: <Widget>[
                (_controller != null &&
                        _controller!.value != null &&
                        _controller!.value.aspectRatio != null)
                    ? Center(
                        child: (image == null)
                              ? new CameraPreview(_controller!)
                              : Image.file(File(image!.path)),
                      )
                    : SizedBox(),
                Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.blue[900]?.withOpacity(
                            0.5) // Specifies the background color and the opacity
                        ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Lokasi terdekat : ${((lokasis != null && lokasis.length > 0) ? lokasis[0]['nama_lokasi'] : "-")}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Jarak : ${_jarak.toStringAsFixed(2)} Meter",
                          style: TextStyle(color: Colors.white),
                        ),
                        (gps)
                            ? ((onspot)
                                ? Text("On Spot",
                                    style: TextStyle(color: Colors.green))
                                : Text("Out Of Range",
                                    style: TextStyle(color: Colors.yellow)))
                            : Text("Gps Not Detected",
                                style: TextStyle(color: Colors.red))
                      ],
                    )),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: (image == null)
          ? Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue[900],
                      heroTag: "btn1",
                      // Provide an onPressed callback.
                      onPressed: () async {
                        _toggleCameraLens();
                      },
                      child: const Icon(Icons.camera_front),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton(
                    backgroundColor: Colors.blue[900],
                    heroTag: "btn2",
                    // Provide an onPressed callback.
                    onPressed: () async {
                      // Take the Picture in a try / catch block. If anything goes wrong,
                      // catch the error.
                      try {
                        // Ensure that the camera is initialized.
                        await _initializeControllerFuture;

                        // Attempt to take a picture and then get the location
                        // where the image file is saved.
                        var xf = await _controller!.takePicture();
                        setState(() {
                          image = xf;
                        });
                      } catch (e) {
                        // If an error occurs, log the error to the console.
                        print("error taking camera");
                        print(e);
                      }
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue[900],
                      heroTag: "btn3",
                      // Provide an onPressed callback.
                      onPressed: () async {
                        if (_controller != null) {
                          setState(() {
                            flash = !flash;
                          });
                          if (flash) {
                            _controller!.setFlashMode(FlashMode.torch);
                          } else {
                            _controller!.setFlashMode(FlashMode.off);
                          }
                        }
                      },
                      child: (flash)
                          ? Icon(Icons.flash_off)
                          : Icon(Icons.flash_on),
                    ),
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FloatingActionButton(
                          backgroundColor: Colors.blue[900],
                          heroTag: "btn4",
                          // Provide an onPressed callback.
                          onPressed: () async {
                            setState(() {
                              image = null;
                            });
                          },
                          child: const Icon(Icons.close),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FloatingActionButton(
                          backgroundColor: Colors.blue[900],
                          heroTag: "btn5",
                          // Provide an onPressed callback.
                          onPressed: () async {
                            if (image != null) {
                              absen(image!.path);
                            }
                          },
                          child: const Icon(Icons.done),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
