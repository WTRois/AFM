import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:absensi/utils/api.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:absensi/pages/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  bool isAuth = false;

  void getSetting() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        var res = await Network().getData('/setting');
        var body = json.decode(res.body);
        if (body['data'] != null) {
          DateTime now = DateTime.now();
          setState(() {
            var data = body['data'];
            localStorage.setString('setting', jsonEncode(data));
            Future.delayed(const Duration(seconds: 2),() {
              _checkIfLoggedIn();
            });
          });
        } else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              text: "Ops gagal menerima data dari server",
              onConfirmBtnTap: () async {
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
              }
          );
        }
      }
    } on SocketException catch (_) {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Ops gagal terhubung, silahkan periksa koneksi internet anda",
          onConfirmBtnTap: () async {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
          }
      );
    }


  }
  
  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.clear();
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: IntroPage()));
    // var token = localStorage.getString('token');
    // if (token != null) {
    //   Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: BottomNavigation()));
    // } else {
    //   Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: IntroPage()));
    // }
  }



  @override
  void initState() {
    super.initState();
    // getSetting();
    Future.delayed(const Duration(seconds: 2),() {
      _checkIfLoggedIn();
    });

  }

  @override
  Widget build(BuildContext context) {
    var imagePath = "assets/images/logo_box.png";
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 36, 115, 227),
              Color.fromARGB(255, 51, 156, 233),
            ],
          )),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Transform.scale(
                          scale: 1.5,
                          child: Stack(
                            children: [
                              Opacity(
                                  child: Image.asset(imagePath,
                                      color: const Color.fromARGB(255, 16, 5, 114)),
                                  opacity: 0.6),
                              ClipRect(
                                  child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5.0, sigmaY: 5.0),
                                      child: Image.asset(imagePath)))
                            ],
                          )),
              )
            ]
            )
        )
      )
    );
  }
}