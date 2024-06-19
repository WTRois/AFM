import 'dart:convert';
import 'package:absensi/components/list_item.dart';
import 'package:badges/badges.dart';
import 'package:absensi/utils/api.dart';
import 'package:flutter/material.dart';

class KalenderJadwalKerjaPage extends StatefulWidget {
  const KalenderJadwalKerjaPage({Key? key}) : super(key: key);

  @override
  _KalenderJadwalKerjaPageState createState() =>
      _KalenderJadwalKerjaPageState();
}

class _KalenderJadwalKerjaPageState extends State<KalenderJadwalKerjaPage> {
  Future<List<dynamic>>? _kalender;
  Future<List<dynamic>>? _jadwals;
  @override
  void initState() {
    super.initState();
    getKalender();
  }

  void getKalender() async {
    var res = await Network().getData('/kalender-jadwal-kerja');
    var body = json.decode(res.body);

    if (body != null && body['data'] != null) {
      setState(() {
        _kalender = Future<List<dynamic>>.value(body['data']['days']);
        _jadwals = Future<List<dynamic>>.value(body['data']['jadwal']);
      });
    } else {
      print(body);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Jadwal Kerja'),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FutureBuilder<List<dynamic>>(
                  future: _kalender,
                  builder: (context, snapshot) {
                    var weekDays = [
                      "Mon",
                      "Tue",
                      "Wed",
                      "Thu",
                      "Fri",
                      "Sat",
                      "Sun"
                    ];
                    if (snapshot.hasData) {
                      List<Widget> data = [];

                      for (var i = 0; i < weekDays.length; i++) {
                        var d = weekDays[i];
                        data.add(Column(
                          children: [
                            Text("${d}"),
                          ],
                        ));
                      }
                      var index =
                          weekDays.indexOf(snapshot.data![0]['day_label']);
                      for (var i = 0; i < snapshot.data!.length + index; i++) {
                        if (i < index) {
                          data.add(Column(
                            children: [
                              const Text("-"),
                            ],
                          ));
                        } else {
                          // var d = snapshot.data![i - index];
                          // List<Widget> j = [];
                          // for (var x = 0; x < d['jadwal_kerja'].length; x++) {
                          //   var jk = d['jadwal_kerja']![x];
                          //   if(jk['status_kerja'] == "work-day"){
                          //     j.add(Badge(
                          //       padding: EdgeInsets.all(2),
                          //       badgeContent: Text(
                          //         jk['id'].toString(),
                          //         style:
                          //             TextStyle(color: Colors.white, fontSize: 9),
                          //       ),
                          //       badgeColor: Colors.green,
                          //       shape: BadgeShape.square,
                          //     ));
                          //   } else {
                          //     j.add(Badge(
                          //       padding: EdgeInsets.all(2),
                          //       badgeContent: Text(
                          //         jk['id'].toString(),
                          //         style:
                          //             TextStyle(color: Colors.white, fontSize: 9),
                          //       ),
                          //       badgeColor: Colors.orange,
                          //       shape: BadgeShape.square,
                          //     ));
                          //   }
                          //
                          // }
                          // data.add(SizedBox(
                          //   // color:
                          //   //     (j.length > 0) ? Colors.white : Colors.red[400],
                          //   height: 100,
                          //   child: Container(
                          //     margin: const EdgeInsets.all(2.0),
                          //     decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.blueAccent)),
                          //     child: Stack(
                          //       children: [
                          //         Positioned.fill(
                          //           child: Padding(
                          //             padding: const EdgeInsets.all(15),
                          //             child: Center(child: Text("${d['day']}",
                          //                 style: TextStyle(fontSize: 12))),
                          //           ),
                          //         ),
                          //         Positioned(
                          //             left: 0,
                          //             top: 0,
                          //             child: (j.length > 0)
                          //                 ? Row(
                          //                     children: j,
                          //                   )
                          //                 : Badge(
                          //                     padding: const EdgeInsets.all(2),
                          //                     badgeContent: const Text(
                          //                       "Off",
                          //                       style: TextStyle(
                          //                           color: Colors.white,
                          //                           fontSize: 10),
                          //                     ),
                          //                     badgeColor: Colors.red,
                          //                     shape: BadgeShape.square,
                          //                   ))
                          //       ],
                          //     ),
                          //   ),
                          // ));
                        }
                      }
                      return GridView.count(
                          shrinkWrap: true, crossAxisCount: 7, children: data);
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
              FutureBuilder<List<dynamic>>(
                future: _jadwals,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> data = [];
                    for (var i = 0; i < snapshot.data!.length; i++) {
                      data.add(Container(
                        margin: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)),
                        child: ListTile(
                          title: Text(
                            "Jadwal ${snapshot.data![i]['id']}",
                            style: TextStyle(color: Colors.green),
                          ),
                          subtitle: Text("${snapshot.data![i]['nama_jadwal']}"),
                        ),
                      ));
                    }
                    return Column(
                      children: data,
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  return SizedBox();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
