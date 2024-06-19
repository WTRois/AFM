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

class TambahTimesheetPage extends StatefulWidget {
  const TambahTimesheetPage({Key? key}) : super(key: key);

  @override
  _TambahTimesheetPageState createState() => _TambahTimesheetPageState();
}

class _TambahTimesheetPageState extends State<TambahTimesheetPage> {
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  var namaTimeSheetController = TextEditingController();
  var tasks = [];
  List<Widget> listData = [
    const Padding(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Text(
          "Task",
          style: TextStyle(fontSize: 16),
        ))
  ];

  simpanData() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    Uri uri = Uri.parse(Network().getUrl() + '/tambah-timesheet');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    var h = {
      "Content-type": "application/json",
      "Accept": "application/json",
      HttpHeaders.authorizationHeader:
          'Bearer ${localStorage.getString('token')}',
    };
    request.headers.addAll(h);

    request.fields['timesheet_name'] = namaTimeSheetController.text.toString();

    for (var i = 0; i < tasks.length; i++) {
      request.fields["task_name[$i]"] = tasks[i]['nama_task'].text.toString();
      var date = tasks[i]['tanggal_task'].text;
      var inputFormat = DateFormat('dd/MM/yyyy');
      var inputDate = inputFormat.parse(date.toString());

      var outputFormat = DateFormat('yyyy-MM-dd');
      var outputDate = outputFormat.format(inputDate);
      request.fields['task_date[$i]'] = outputDate.toString();
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

  void getTask() {
    setState(() {
      tasks = [
        {
          'nama_task': TextEditingController(),
          'tanggal_task': TextEditingController(),
        },
        {
          'nama_task': TextEditingController(),
          'tanggal_task': TextEditingController(),
        }
      ];

      for (var i = 0; i < tasks.length; i++) {
        listData.add(Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //                 <--- border radius here
                ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: InkWell(
                  child: Container(
                    child: TextFormField(
                      controller:
                          tasks[i]['tanggal_task'] as TextEditingController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '1/2/2022',
                      ),
                      readOnly: true,
                      enabled: false,
                    ),
                  ),
                  onTap: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        locale: LocaleType.id,
                        currentTime: DateTime.now(),
                        onChanged: (date) {}, onConfirm: (date) {
                      var inputFormat = DateFormat('yyyy-MM-dd');
                      var inputDate = inputFormat.parse(date.toString());

                      var outputFormat = DateFormat('dd/MM/yyyy');
                      var outputDate = outputFormat.format(inputDate);
                      tasks[i]['tanggal_task'].text = outputDate.toString();
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: tasks[i]['nama_task'] as TextEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan isi nama Timesheet';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Nama Task....',
                  ),
                ),
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      tasks.removeAt(i);
                      listData.removeAt(i + 1);
                    });
                  },
                  icon: Icon(Icons.delete),
                  label: Text("Hapus"),
                  style: ElevatedButton.styleFrom(primary: Colors.red))
            ],
          ),
        ));
      }
    });
  }

  void addTask() {
    setState(() {
      var task = {
        'nama_task': TextEditingController(),
        'tanggal_task': TextEditingController(),
      };
      tasks.add(task);
      var i = tasks.length - 1;
      listData.add(Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: InkWell(
                child: Container(
                  child: TextFormField(
                    controller:
                        tasks[i]['tanggal_task'] as TextEditingController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '1/2/2022',
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                ),
                onTap: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      locale: LocaleType.id,
                      currentTime: DateTime.now(),
                      onChanged: (date) {}, onConfirm: (date) {
                    var inputFormat = DateFormat('yyyy-MM-dd');
                    var inputDate = inputFormat.parse(date.toString());

                    var outputFormat = DateFormat('dd/MM/yyyy');
                    var outputDate = outputFormat.format(inputDate);
                    tasks[i]['tanggal_task'].text = outputDate.toString();
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                controller: tasks[i]['nama_task'] as TextEditingController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silahkan isi nama Timesheet';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Nama Task....',
                ),
              ),
            ),
            ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    tasks.removeAt(i);
                    listData.removeAt(i + 1);
                  });
                },
                icon: Icon(Icons.delete),
                label: Text("Hapus"),
                style: ElevatedButton.styleFrom(primary: Colors.red))
          ],
        ),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    getTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Timesheet'),
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
                    const Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: Text(
                          "Nama Timesheet",
                          style: TextStyle(fontSize: 16),
                        )),
                    TextFormField(
                      controller: namaTimeSheetController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silahkan isi nama Timesheet';
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
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: listData,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              addTask();
                            },
                            icon: Icon(Icons.add),
                            label: Text("Tambah"),
                          )
                        ],
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
                ))),
      ),
    );
  }
}
