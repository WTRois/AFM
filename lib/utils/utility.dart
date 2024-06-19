import 'package:absensi/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  showMsg(msg,context) {
      final snackBar = SnackBar(
        content: Text(msg),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> showAlert(title,message,context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message.toString()),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showLoaderDialog(BuildContext context){
    MyApp.loading = true;
    AlertDialog alert =
    AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(
      barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  closeLoaderDialog(BuildContext context){
    MyApp.loading = false;
    Navigator.pop(context);
  }
}