import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:absensi/pages/login_page.dart';
import 'package:absensi/pages/splash_screen_page.dart';
import 'package:absensi/utils/api.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        final isValidHost = [
          'absensi.aplikasipos.id',
          '192.168.8.217',
          'absensi.suemerugrup.com',
          'suemerugrup.com'
        ].contains(host);
        return isValidHost;
      };
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static bool loading = false;
  static bool openGaleri = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => const AppRoot();
}

class AppRoot extends StatefulWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  AppRootState createState() => AppRootState();
}

class AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  AppLifecycleState? _notification;
  Timer? _timer;
  final navigatorKey = GlobalKey<NavigatorState>();
  bool forceLogout = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.paused && !MyApp.openGaleri) {
        _logOutUser();
      }
      _notification = state;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getSetting();
    WidgetsBinding.instance.addObserver(this);
  }

  void getSetting() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        var _url = Network().getUrl();
        var fullUrl = Uri.parse(_url + "/setting");
        var res = await http
            .get(
              fullUrl,
            )
            .timeout(Duration(seconds: 60));
        var body = json.decode(res.body);
        if (body['data'] != null) {
          DateTime now = DateTime.now();
          setState(() {
            var data = body['data'];
            localStorage.setString('setting', jsonEncode(data));
            _initializeTimer();
          });
        }
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
            });
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
          });
    }
  }

  void _initializeTimer() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.getString("setting") != null) {
      var setting = json.decode(localStorage.getString('setting')!);
      int m = int.parse(setting['waktu_logout_app'] ?? 0);
      setState(() {
        forceLogout = false;
        if (_timer != null) {
          _timer!.cancel();
        }
        _timer = Timer(Duration(minutes: m), _logOutUser);
      });
    }
  }

  void _logOutUser() {
    if (MyApp.loading) {
      _initializeTimer();
      return;
    }
    _timer?.cancel();
    _timer = null;
    setState(() {
      forceLogout = true;
    });
  }

  void navToLoginPage(BuildContext context) async {
    //Clear all pref's
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.getString("token") != null) {
      localStorage.remove("token");
      //localStorage.remove("user");
      //localStorage.clear();
      navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false);
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => const LoginPage()),
      //   (Route<dynamic> route) => false,
      // );
    } else {
      setState(() {
        forceLogout = false;
        _timer?.cancel();
        _timer = null;
      });
    }
  }

  void _handleUserInteraction([_]) {
    _initializeTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (forceLogout) {
      navToLoginPage(context);
    }
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _handleUserInteraction,
            onPanDown: _handleUserInteraction,
            onDoubleTap: _handleUserInteraction,
            onVerticalDragStart: _handleUserInteraction,
            onHorizontalDragStart: _handleUserInteraction,
            child: MaterialApp(
              navigatorKey: navigatorKey,
              title: 'SUEMERUgrup',
              theme: ThemeData(
                primaryColor: Colors.blue.shade900,
              ),
              home: const SplashScreenPage(),
            ));
      },
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({Key? key}) : super(key: key);

  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove("token");
    //localStorage.remove("user");
    //localStorage.clear();
    // var token = localStorage.getString('token');
    // if (token != null) {
    //   if (mounted) {
    //     setState(() {
    //       isAuth = true;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    // Widget child;
    // if (isAuth) {
    //   child = BottomNavigation();
    // } else {
    //   child = LoginPage();
    // }

    return Scaffold(
      body: LoginPage(),
    );
  }
}
