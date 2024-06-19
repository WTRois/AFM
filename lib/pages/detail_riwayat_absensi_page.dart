import 'dart:convert';
import 'dart:io';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:absensi/utils/api.dart';
import 'package:absensi/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';

class DetailRiwayatAbsensiPage extends StatefulWidget {
  final int id;
  const DetailRiwayatAbsensiPage({Key? key, required this.id})
      : super(key: key);

  @override
  _DetailRiwayatAbsensiPageState createState() =>
      _DetailRiwayatAbsensiPageState();
}

class _DetailRiwayatAbsensiPageState extends State<DetailRiwayatAbsensiPage> {
  late final MapController mapController;
  var data;
  String? _linkFoto;
  String? token;
  LocationData? _locationData;
  void getRiwayat() async {
    Utility().showLoaderDialog(context);
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      token = localStorage.getString('token');
      var res = await Network().getData('/riwayat-absensi/${widget.id}');
      var body = json.decode(res.body);
      if (body['data'] != null) {
        DateTime now = DateTime.now();
        Future.delayed(Duration.zero, () {
          setState(() {
            data = body['data'];
            if (data['foto_absen'] != null) {
              _linkFoto =
                  Network().getUrl() + '/riwayat-absensi/${widget.id}/foto';
            }
          });
        });
      } else {
        print(body);
      }
    } catch (e) {
      print(e);
    }
    Utility().closeLoaderDialog(context);
  }

  Future<LatLng?> _acquireCurrentLocation() async {
    Location location = new Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      _locationData = locationData;
    });
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value.toDouble();
    }
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    Future.delayed(Duration.zero, () {
      getRiwayat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Absensi'),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: () async {
            getRiwayat();
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: (data != null)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      (data['latitude'] != null)
                          ? Container(
                              height: 300,
                              child:
                                  // MapboxMap(
                                  //   initialCameraPosition: CameraPosition(
                                  //     target: LatLng(checkDouble(data['latitude']),
                                  //         checkDouble(data['longitude'])),
                                  //     zoom: 15,
                                  //   ),
                                  //   accessToken:
                                  //       "sk.eyJ1IjoiYmFndXNpbmRyYXlhbmEiLCJhIjoiY2wzbnV5M3hjMGdveDNwbnlobW9yMmh0ZCJ9.1IKlWm2uMd_VCUPnE9yNEA",
                                  //   onMapCreated: (controller) {
                                  //     // _acquireCurrentLocation().then((LatLng? location) {

                                  //     // }).catchError((error) => print(error));
                                  //     if (data != null) {
                                  //       var location = LatLng(
                                  //           checkDouble(data['latitude']),
                                  //           checkDouble(data['longitude']));
                                  //       Future.delayed(Duration.zero, () {
                                  //         controller.addSymbol(SymbolOptions(
                                  //           geometry: location,
                                  //           iconImage: 'marker',
                                  //           iconSize: 1,
                                  //         ));
                                  //         controller.addCircle(
                                  //           CircleOptions(
                                  //             geometry: location,
                                  //             circleColor: "#3878ff",
                                  //             circleRadius: 6,
                                  //           ),
                                  //         );
                                  //       });
                                  //     }
                                  //   },
                                  // ),
                                  FlutterMap(
                                mapController: mapController,
                                options: new MapOptions(
                                  center: new latlong2.LatLng(
                                      checkDouble(data['latitude']),
                                      checkDouble(data['longitude'])),
                                  zoom: 13.0,
                                ),
                                layers: [
                                  new TileLayerOptions(
                                      urlTemplate:
                                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                      subdomains: ['a', 'b', 'c']),
                                  new MarkerLayerOptions(
                                    markers: [
                                      new Marker(
                                        width: 20.0,
                                        height: 20.0,
                                        point: new latlong2.LatLng(
                                      checkDouble(data['latitude']),
                                      checkDouble(data['longitude'])),
                                        builder: (ctx) => new Container(
                                          child: Icon(Icons.place,color: Colors.blue,),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ))
                          : const SizedBox(),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Absen",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['jenis_absen']}",
                              style: TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tanggal Absen",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['tanggal_absen']}",
                              style: TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Waktu Absen",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['waktu_absen']}",
                              style: TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Keterangan",
                              style: TextStyle(fontSize: 14),
                            ),
                            (data['keterangan'] != null)
                                ? Text(
                                    "${data['keterangan']}",
                                    style: TextStyle(fontSize: 14),
                                  )
                                : Text("-")
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Jadwal Kerja",
                              style: TextStyle(fontSize: 14),
                            ),
                            (data['jadwal_kerja'] != null)
                                ? Text(
                                    "${data['jadwal_kerja']['nama_jadwal']}",
                                    style: TextStyle(fontSize: 14),
                                  )
                                : Text("-")
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Lokasi Absen",
                              style: TextStyle(fontSize: 14),
                            ),
                            (data['lokasi_absen'] != null)
                                ? Text(
                                    "${data['lokasi_absen']['nama_lokasi']}",
                                    style: TextStyle(fontSize: 14),
                                  )
                                : Text("-")
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Status Absen",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['status']}",
                              style: TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Foto"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
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
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [CircularProgressIndicator()],
                  ),
          ),
        ),
      ),
    );
  }
}
