import 'dart:convert';
import 'package:absensi/models/Article.dart';
import 'package:absensi/pages/login_page.dart';
import 'package:absensi/pages/menu_absen_page.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:absensi/utils/api.dart';
import 'package:absensi/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool is_user = false;
  var userJson = null;
  var jadwal = "00:00 - 00:00";
  bool isLoadingArticle = true;

  void logout() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove("token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void getProfil() async {
    Utility().showLoaderDialog(context);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    try {
      var res = await Network().getData('/profil');
      var body = json.decode(res.body);
      if (res.statusCode == 401) {
        Utility().closeLoaderDialog(context);
        CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: "Ops ada yang salah, silahkan login kembali",
            onConfirmBtnTap: () {
              logout();
            });
      } else {
        if (body['data'] != null) {
          setState(() {
            userJson = body['data'];
            localStorage.setString('_type', userJson['_type']);
            localStorage.setString('user', json.encode(userJson));
            if (userJson['jadwal_kerja_hari_ini'] != null) {
              var formatDate = DateFormat('HH:mm:ss');
              var jamMasuk = formatDate
                  .parse(userJson['jadwal_kerja_hari_ini']['jam_masuk']);
              var outputFormat = DateFormat('HH:mm').format(jamMasuk);
              var jamPulang = formatDate
                  .parse(userJson['jadwal_kerja_hari_ini']['jam_pulang']);
              var outputFormat2 = DateFormat('HH:mm').format(jamPulang);
              jadwal = "${outputFormat} - ${outputFormat2}";
            }
            if (userJson['_type'] == "user") {
              is_user = true;
            } else {
              is_user = false;
            }
          });
          Utility().closeLoaderDialog(context);
        } else if (body['error'] != null) {
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: body['error'].toString(),
          );
        } else {
          Utility().closeLoaderDialog(context);
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: "Ada masalah saat menampilkan data",
          );
        }
      }
    } catch (e) {
      print(e);
      Utility().closeLoaderDialog(context);
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Ada masalah saat menampilkan data." + e.toString(),
      );
    }
  }

  Future<List<Article>>? _riwayatArticle;
  void getArticle() async => await fetchArticle().then((value) {
        setState(() {
          isLoadingArticle = false;
          _riwayatArticle = Future<List<Article>>.value(value);
        });
      }).onError((error, stackTrace) {
        setState(() {
          isLoadingArticle = false;
        });
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Ada masalah saat menampilkan data article",
        );
      });

  void bukaArticle(url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getProfil();
      getArticle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          backgroundColor: Colors.blue[900],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              getProfil();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
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
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Selamat Datang, " +
                          ((userJson != null) ? userJson['nama'] : ""),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                (userJson == null)
                    ? Container(
                        margin: EdgeInsets.only(
                            left: 30, top: 20, right: 30, bottom: 50),
                        child: SkeletonLine(
                          style: SkeletonLineStyle(
                              height: 70,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(10)),
                        ))
                    : (!is_user)
                        ? InkWell(
                            child: MirrorAnimation<double>(
                              duration: const Duration(seconds: 1),
                              tween: Tween(begin: 0, end: 4),
                              curve: Curves.easeOutCubic,
                              builder: (context, child, value) {
                                return Container(
                                  child: child,
                                  margin: const EdgeInsets.only(
                                      left: 30, top: 20, right: 30, bottom: 50),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 6, 27, 121)
                                            .withOpacity(0.5),
                                        spreadRadius: 2 + value,
                                        blurRadius: 4 + value,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5, right: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Icon(
                                        Icons.pending_actions,
                                        color: Colors.blue[900],
                                        size: 50,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              ((userJson != null &&
                                                      userJson[
                                                              'jadwal_kerja_hari_ini'] !=
                                                          null)
                                                  ? "Silahkan Absen (${jadwal})"
                                                  : "Tidak Ada Jadwal Hari Ini"),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue),
                                              textAlign: TextAlign.start),
                                          Text("Masuk/Pulang/Izin",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.blue[900]),
                                              textAlign: TextAlign.start)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MenuAbsenPage()),
                              );
                            },
                          )
                        : Container(
                            margin: const EdgeInsets.only(
                                left: 30, top: 20, right: 30, bottom: 30),
                            child: SizedBox(),
                          ),
                (is_user)
                    ? GridView.count(
                        shrinkWrap: true,
                        primary: false,
                        crossAxisCount: 4,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Icon(Icons.local_atm,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  primary: Colors.blue[900], // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 5),
                                child: Text(
                                  "Finance",
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Icon(Icons.people,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  primary: Colors.blue[900], // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 5),
                                child: Text(
                                  "HR Report",
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Icon(Icons.engineering,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  primary: Colors.blue[900], // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 5),
                                child: Text(
                                  "Production Report",
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Icon(Icons.local_gas_station,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  primary: Colors.blue[900], // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 5),
                                child: Text(
                                  "Fuel Report",
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Icon(Icons.inventory,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  primary: Colors.blue[900], // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 5),
                                child: Text(
                                  "Logistic Report",
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Icon(Icons.health_and_safety,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  primary: Colors.blue[900], // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 5),
                                child: Text(
                                  "K3LH Management",
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Icon(Icons.bar_chart,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  primary: Colors.blue[900], // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 5),
                                child: Text(
                                  "Barging & Trading Activities",
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : SizedBox(),
                Divider(),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Articles",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold)),
                ),
                isLoadingArticle
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.all(50),
                          child: const CircularProgressIndicator(),
                        ),
                      )
                    : FutureBuilder<List<Article>>(
                        future: _riwayatArticle,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Widget> dataArticle = [];
                            for (var i = 0; i < snapshot.data!.length; i++) {
                              Article article = snapshot.data![i];
                              dataArticle.add(InkWell(
                                onTap: () {
                                  bukaArticle(article.link);
                                },
                                child: Card(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          width: 100,
                                          height: 100,
                                          margin: const EdgeInsets.all(15.0),
                                          padding: const EdgeInsets.all(3.0),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  article.thumbnail),
                                            ),
                                            color: Colors.blue[900],
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                      Expanded(
                                          child: Container(
                                        height: 100,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 20, left: 10, right: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("${article.title}",
                                                  // maxLines: 1,
                                                  // softWrap: false,
                                                  // overflow:
                                                  //     TextOverflow.fade,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue[900])),
                                              Text(
                                                "${article.date}",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ));
                            }
                            if (dataArticle.isEmpty) {
                              dataArticle.add(const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text('Tidak ada data'),
                                ),
                              ));
                            }
                            return Column(
                              children: dataArticle,
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }

                          // By default, show a loading spinner.
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.all(50),
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                // Card(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Container(
                //         width: 100,
                //         height: 100,
                //         margin: const EdgeInsets.all(15.0),
                //         padding: const EdgeInsets.all(3.0),
                //         decoration: BoxDecoration(
                //           color: Colors.blue[900],
                //           borderRadius: BorderRadius.circular(10.0),
                //         ),
                //         child: SizedBox(),
                //       ),
                //       Padding(
                //         padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text("Lorem ipsum dolor sit amet",
                //                 style: TextStyle(
                //                     fontSize: 16, color: Colors.blue[900])),
                //             Text(
                //               "Admin - 2022-01-01",
                //               style:
                //                   TextStyle(fontSize: 12, color: Colors.blue),
                //             )
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Card(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Container(
                //         width: 100,
                //         height: 100,
                //         margin: const EdgeInsets.all(15.0),
                //         padding: const EdgeInsets.all(3.0),
                //         decoration: BoxDecoration(
                //           color: Colors.blue[900],
                //           borderRadius: BorderRadius.circular(10.0),
                //         ),
                //         child: SizedBox(),
                //       ),
                //       Padding(
                //         padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text("Lorem ipsum dolor sit amet",
                //                 style: TextStyle(
                //                     fontSize: 16, color: Colors.blue[900])),
                //             Text(
                //               "Admin - 2022-01-01",
                //               style:
                //                   TextStyle(fontSize: 12, color: Colors.blue),
                //             )
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // )
              ],
            )));
  }
}
