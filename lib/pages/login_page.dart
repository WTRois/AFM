import 'dart:io';

import 'package:absensi/bottom_navigation.dart';
import 'package:absensi/pages/lupa_password.dart';
import 'package:absensi/utils/api.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final LocalAuthentication auth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  var email = TextEditingController();
  var password = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _secureText = true;
  bool rememeberMe = false;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  void checkSavedEmail() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var _email = localStorage.getString('email');
    if(_email != null){
      setState(() {
        rememeberMe = true;
      email.text = _email;
      });
    }
   
    
  }

  void _startBioMetricAuth(String message,user) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = jsonDecode(user);
    if( userJson['token'] == null){
      return;
    }
    try {
      bool didAuthenticate = await auth.authenticate(localizedReason: message);
      if (didAuthenticate) {
       
        
        localStorage.setString('token', userJson['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigation()),
        );
      } else {
        
      }
    } on PlatformException catch (e) {
      
      if (e.code == auth_error.notAvailable) {
        print("Error!");
      } else {
        print(e.toString());
      }
    }
  }

  void _auth() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var _user = localStorage.getString('user');
    var _email = localStorage.getString('email');
    if(_user != null && _email != null){
      // _user = jsonDecode(_user);
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

      if (Platform.isIOS) {
        if (availableBiometrics.contains(BiometricType.face)) {
          print("Face");
          _startBioMetricAuth("Gunakan Face ID untuk melakukan autentikasi.",_user);
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          print("Finger");
          _startBioMetricAuth("Gunakan Touch ID untuk melakukan autentikasi.",_user);
        } else {
            print("no bimetrict");
          }
      } else {
        if (availableBiometrics.contains(BiometricType.strong) ||
              availableBiometrics.contains(BiometricType.fingerprint)) {
            _startBioMetricAuth("Gunakan Fingerprint untuk melakukan autentikasi.",_user);
          } else {
            print("no bimetrict");
          }
        
      }
      
    }
    
    
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkSavedEmail();
      _auth();
    });
  }

  void _login() async {
    showLoaderDialog(context);
    setState(() {
      _isLoading = true;
    });
    var data = {'email': email.text, 'password': password.text};

    try {
      var res = await Network().auth(data, '/login');
      var body = json.decode(res.body);

      if (body['data'] != null) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        // localStorage.clear();
        if(rememeberMe){
          localStorage.setString("email", email.text);
        } else {
          localStorage.remove("email");
        }
        body['data']['user']['token'] = body['data']['token'];

        localStorage.setString('token', body['data']['token']);
        localStorage.setString('_type', body['data']['_type']);
        localStorage.setString('user', json.encode(body['data']['user']));
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigation()),
        );
      } else {
        Navigator.pop(context);
        if (body['error'] != null) {
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: body['error'],
          );
          // Utility().showMsg(body['error'], context);
        } else {
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: "Terjadi kesalahan, silahkan coba lagi",
          );

          //Utility().showMsg('Terjadi kesalahan, silahkan coba lagi', context);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Terjadi kesalahan, silahkan coba lagi",
      );
      print(e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bool isValidPhoneNumber(String string) {
    // Null or empty string is invalid email
    if (string == null || string.isEmpty) {
      return false;
    }

    // You may need to change this pattern to fit your requirement.
    // I just copied the pattern from here: https://regexr.com/3c53v
    const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
      return false;
    }
    return true;
  }

  bool isValidEmail(String string) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(string);
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.white;
      }
      return Colors.blue;
    }
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Login Page'),
        // ),
        body: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 25.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/top.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: 100,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 65.h,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg2.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Form(
                key: _formKey,
                // autovalidateMode: AutovalidateMode.always,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else {
                            if (!isValidEmail(value)) {
                              return 'Please enter a valid email';
                            }
                          }

                          return null;
                        },
                        controller: email,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        validator: (passwordValue) {
                          if (passwordValue == null || passwordValue.isEmpty) {
                            return 'Please enter your password';
                          }

                          return null;
                        },
                        controller: password,
                        obscureText: _secureText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _secureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              setState(() {
                                _secureText = !_secureText;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          primary: Colors.white // NEW
                          ),
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Remember Me",style: TextStyle(color: Colors.white),),
                        Checkbox(
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith(getColor),
                          value: rememeberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              rememeberMe = value!;
                            });
                          },
                        )
                      ],
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
          InkWell(
                      child: Container(
                        child: Text(
                          'Lupa password ?',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LupaPasswordPage(),
                          ),
                        );
                      },
                    )
        ],
      ),
    ));
  }
}
