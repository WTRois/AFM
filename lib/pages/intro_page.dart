import 'dart:ui';
import 'package:absensi/pages/login_page.dart';
import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:page_transition/page_transition.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  var control1 = CustomAnimationControl.stop;

  openLogin() async {
    setState(() {
      control1 = CustomAnimationControl.play;
    });
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var imagePath = "assets/images/logo_box.png";
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: null,
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
                alignment: Alignment.topCenter,
                child: PlayAnimation<double>(
                  duration: const Duration(seconds: 1),
                  delay: const Duration(
                      seconds: 2), // bind state variable to parameter
                  tween: Tween(begin: 0, end: -(height / 2) + 200),
                  curve: Curves.easeOutCubic,
                  builder: (context, child, value) {
                    return Transform.translate(
                      // animation that moves childs from left to right
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: Transform.translate(
                      offset: Offset(0, height / 2 - 100),
                      child: Transform.scale(
                          scale: 1.5,
                          child: Stack(
                            children: [
                              Opacity(
                                  child: Image.asset(imagePath,
                                      color: Color.fromARGB(255, 16, 5, 114)),
                                  opacity: 0.6),
                              ClipRect(
                                  child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5.0, sigmaY: 5.0),
                                      child: Image.asset(imagePath)))
                            ],
                          ))),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: PlayAnimation<double>(
                  duration: const Duration(seconds: 1),
                  delay: const Duration(
                      seconds: 2), // bind state variable to parameter
                  tween: Tween(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, child, value) {
                    var x = (2 - value) / (2 - 0.7);
                    var y = (1.5 - value) / (1.5 - 0.5);
                    return FractionalTranslation(
                        translation: Offset(x, y), child: child);
                  },
                  child: Transform.scale(
                    scale: 5.5,
                    child: Blob.fromID(
                      id: ['6-4-2605'],
                      size: 400,
                      styles: BlobStyles(
                        color: Color.fromARGB(255, 77, 158, 233),
                        fillType: BlobFillType.stroke,
                        strokeWidth: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: PlayAnimation<double>(
                  duration: const Duration(seconds: 1),
                  delay: const Duration(
                      seconds: 2), // bind state variable to parameter
                  tween: Tween(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, child, value) {
                    var x = (2 - value) / (2 - 0.7);
                    var y = (1.5 - value) / (1.5 - 0.5);
                    return FractionalTranslation(
                        translation: Offset(x, y), child: child);
                  },
                  child: CustomAnimation<double>(
                    control: control1,
                    duration: Duration(
                        milliseconds: 1500), // bind state variable to parameter
                    tween: Tween(begin: 1, end: 4),
                    builder: (context, child, value) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Transform.scale(
                      scale: 4.7,
                      child: Blob.fromID(
                        id: ['6-4-2605'],
                        size: 400,
                        styles: BlobStyles(
                          color: Color.fromARGB(255, 55, 51, 191),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: PlayAnimation<double>(
                  duration: const Duration(seconds: 1),
                  delay: const Duration(
                      milliseconds: 2250), // bind state variable to parameter
                  tween: Tween(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, child, value) {
                    var x = (2 - value) / (2 - 0.7);
                    var y = (1.5 - value) / (1.5 - 0.5);
                    return FractionalTranslation(
                        translation: Offset(x, y), child: child);
                  },
                  child: CustomAnimation<double>(
                    control: control1,
                    duration: Duration(seconds: 1),
                    delay: Duration(milliseconds: 500),
                    tween: Tween(begin: 1, end: 4),
                    builder: (context, child, value) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Transform.scale(
                      scale: 3.5,
                      child: Blob.fromID(
                        id: ['6-4-2605'],
                        size: 400,
                        styles: BlobStyles(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: PlayAnimation<double>(
                  duration: const Duration(seconds: 1),
                  delay: const Duration(
                      milliseconds: 2800), // bind state variable to parameter
                  tween: Tween(begin: -1, end: 0),
                  curve: Curves.easeOutCubic,
                  builder: (context, child, value) {
                    return FractionalTranslation(
                        translation: Offset(value, 0), child: child);
                  },
                  child: CustomAnimation<double>(
                    control: control1,
                    duration: Duration(
                        milliseconds: 700), // bind state variable to parameter
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, child, value) {
                      return FractionalTranslation(
                          translation: Offset(0, value), child: child);
                    },
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: InkWell(
                            child: Container(
                          width: 100,
                          child: Text(
                            'Need Help ?',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ))),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: PlayAnimation<double>(
                  duration: const Duration(seconds: 1),
                  delay: const Duration(
                      milliseconds: 2800), // bind state variable to parameter
                  tween: Tween(begin: 1, end: 0),
                  curve: Curves.easeOutCubic,
                  builder: (context, child, value) {
                    return FractionalTranslation(
                        translation: Offset(value, 0), child: child);
                  },
                  child: CustomAnimation<double>(
                    control: control1,
                    duration: Duration(
                        milliseconds: 700), // bind state variable to parameter
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, child, value) {
                      return FractionalTranslation(
                          translation: Offset(0, value), child: child);
                    },
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: InkWell(
                            child: Container(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Log in',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Icon(
                                    Icons.navigate_next,
                                    size: 36,
                                    color: Color.fromARGB(255, 36, 115, 227),
                                  )
                                ],
                              ),
                            ),
                            onTap: () {
                              openLogin();
                            })),
                  ),
                ),
              )
            ],
          ),
          constraints: BoxConstraints.expand(),
        ),
      ),
    );
  }
}
