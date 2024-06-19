import 'dart:convert';
import 'dart:io';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:absensi/utils/api.dart';
import 'package:absensi/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailKunjunganPage extends StatefulWidget {
  final int id;
  const DetailKunjunganPage({Key? key, required this.id})
      : super(key: key);

  @override
  _DetailKunjunganPageState createState() =>
      _DetailKunjunganPageState();
}

class _DetailKunjunganPageState extends State<DetailKunjunganPage> {
  var data;
  String? visit_in_signature;
  String? visit_out_signature;
  String? token;
  LocationData? _locationData;
  void getRiwayat() async {
    Utility().showLoaderDialog(context);
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      token = localStorage.getString('token');
      var res = await Network().getData('/riwayat-kunjungan/${widget.id}');
      var body = json.decode(res.body);
      if (body['data'] != null) {
        DateTime now = DateTime.now();
        Future.delayed(Duration.zero, () {
          setState(() {
            data = body['data'];
            visit_in_signature = Network().getUrl() + '/riwayat-kunjungan/${widget.id}/tanda-tangan?type=visit_in_signature';
            visit_out_signature = Network().getUrl() + '/riwayat-kunjungan/${widget.id}/tanda-tangan?type=visit_out_signature';
            
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
                      (data['latitude'] != null)?Container(
                        height: 300,
                        child: MapboxMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(checkDouble(data['latitude']),
                                checkDouble(data['longitude'])),
                            zoom: 15,
                          ),
                          accessToken:
                              "sk.eyJ1IjoiYmFndXNpbmRyYXlhbmEiLCJhIjoiY2wzbnV5M3hjMGdveDNwbnlobW9yMmh0ZCJ9.1IKlWm2uMd_VCUPnE9yNEA",
                          onMapCreated: (controller) {
                            // _acquireCurrentLocation().then((LatLng? location) {

                            // }).catchError((error) => print(error));
                            if (data != null) {
                              var location = LatLng(
                                  checkDouble(data['latitude']),
                                  checkDouble(data['longitude']));
                              Future.delayed(Duration.zero, () {
                                controller.addSymbol(SymbolOptions(
                                  geometry: location,
                                  iconImage: 'marker',
                                  iconSize: 1,
                                ));
                                controller.addCircle(
                                  CircleOptions(
                                    geometry: location,
                                    circleColor: "#3878ff",
                                    circleRadius: 6,
                                  ),
                                );
                              });
                            }
                          },
                        ),
                      ):SizedBox(),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Nama Kunjungan",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['nama_kunjungan']}",
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
                              "Visit In",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['visit_in']}",
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
                              "Visit In Note",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['visit_in_note']}",
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
                              "Visit Out",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['visit_out']}",
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
                              "Visit Out Note",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "${data['visit_out_note']}",
                              style: TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Foto Signature"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: (visit_in_signature != null && token != null)
                            ? Image.network(visit_in_signature!, headers: {
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
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: (visit_out_signature != null && token != null)
                            ? Image.network(visit_out_signature!, headers: {
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
