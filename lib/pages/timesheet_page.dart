import 'dart:convert';
import 'package:absensi/components/list_item.dart';
import 'package:absensi/pages/detail_timesheet_page.dart';
// import 'package:absensi/pages/tambah_timesheet_page.dart';
// import 'package:absensi/pages/ubah_timesheet_page.dart';
import 'package:absensi/utils/api.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimesheetPage extends StatefulWidget {
  const TimesheetPage({Key? key}) : super(key: key);

  @override
  _TimesheetPageState createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  bool isLoading = true;

  Future<List<dynamic>>? _riwayatTimesheet;
  void getTimesheet() async {
    var res = await Network().getData('/riwayat-timesheet');
    var body = json.decode(res.body);
    if (body != null && body['data'] != null) {
      setState(() {
        _riwayatTimesheet = Future<List<dynamic>>.value(body['data']);
        isLoading = false;
      });
    } else {
      if (body['error'] != null) {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: body['error'].toString(),
        );
      } else {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: body.toString(),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getTimesheet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheet'),
        backgroundColor: Colors.blue[900],
      ),
      body: RefreshIndicator(
        onRefresh: () async{
            getTimesheet();
          },
        child: ListView(
          
          children: [
            isLoading
                ? Center(
                    child: Container(
                      margin: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : FutureBuilder<List<dynamic>>(
                    future: _riwayatTimesheet,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Widget> dataAbsen = [];
                        for (var i = 0; i < snapshot.data!.length; i++) {
                          var formatDate = DateFormat('yyyy-MM-ddTHH:mm:ssZ');
                          var createdAt =
                              formatDate.parse(snapshot.data![i]['created_at']);
                          var outputFormat = DateFormat('yyyy-MM-dd');
                          var outputDate = outputFormat.format(createdAt);
                          dataAbsen.add(ListItem(
                              title: snapshot.data![i]['timesheet_name'],
                              subTitle: "${outputDate.toString()}",
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DetailTimsheetPage(
                                      id: snapshot.data![i]['id']),
                                ));
                              }));
                        }
                        if (dataAbsen.length == 0) {
                          dataAbsen.add(const Center(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Tidak ada data'),
                            ),
                          ));
                        }
                        return Column(
                          children: dataAbsen,
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      return Center(
                        child: Container(
                          margin: EdgeInsets.all(50),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(MaterialPageRoute(
      //       builder: (context) => TambahTimesheetPage(),
      //     ));
      //   },
      //   child: const Icon(Icons.add),
      //   backgroundColor: Colors.blue[900],
      // ),
    );
  }
}
