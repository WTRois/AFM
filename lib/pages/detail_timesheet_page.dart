import 'dart:convert';
import 'dart:io';
import 'package:absensi/utils/api.dart';
import 'package:absensi/utils/utility.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailTimsheetPage extends StatefulWidget {
  final int id;
  const DetailTimsheetPage({Key? key, required this.id}) : super(key: key);

  @override
  _DetailTimsheetPageState createState() => _DetailTimsheetPageState();
}

class _DetailTimsheetPageState extends State<DetailTimsheetPage> {
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  var data;


  List<Widget> listData = [
    const Padding(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Text(
          "Task",
          style: TextStyle(fontSize: 16),
        ))
  ];


  void getTask() async {
    Utility().showLoaderDialog(context);
    var res = await Network().getData('/timesheet/' + widget.id.toString());
    var body = json.decode(res.body);
    if (body['data'] != null) {
      setState(() {
        data = body['data'];
      });
      

      setState(() {
        for (var i = 0; i < data['timesheet_detail'].length; i++) {
          listData.add(Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.all(Radius.circular(
                      5.0) //                 <--- border radius here
                  ),
            ),
            child: Column(
              children: [
                Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tanggal Task",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "${data['timesheet_detail'][i]['task_date']}",
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
                    "Nama Task",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "${data['timesheet_detail'][i]['task_name']}",
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
            ),
              ],
            ),
          ));
        }
      });
      Utility().closeLoaderDialog(context);
    } else {
      Utility().closeLoaderDialog(context);
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: body.toString(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getTask();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Timesheet'),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
                key: _formKey,
                child: (data != null)?Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nama Timesheet",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            "${data['timesheet_name']}",
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //                 <--- border radius here
                            ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: listData,
                      ),
                    )
                  ],
                ):Center(
                  child: CircularProgressIndicator(),
                )
              )
            ),
      ),
    );
  }
}
