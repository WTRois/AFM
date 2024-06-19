import 'package:absensi/pages/akun_page.dart';
import 'package:absensi/pages/home_page.dart';
import 'package:absensi/pages/inbox_page.dart';
import 'package:absensi/pages/news_page.dart';
import 'package:absensi/pages/web_page.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class CustomStyle extends StyleHook {
  @override
  double get activeIconSize => 40;

  @override
  double get activeIconMargin => 10;

  @override
  double get iconSize => 24;

  @override
  TextStyle textStyle(Color color) {
    return TextStyle(fontSize: 12, color: color);
  }
}

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedNavbar = 0;
  final List<Widget> _pages = [
    HomePage(),
    NewsPage(),
    WebPage(),
    InboxPage(),
    AkunPage()
  ];

  void _changeSelectedNavBar(int index) {
    setState(() {
      _selectedNavbar = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Center(child: Text("Absen Lokasi"),),
        //   backgroundColor: Colors.blue[900],
        // ),

        body: _pages.elementAt(_selectedNavbar),
        bottomNavigationBar: StyleProvider(
          style: CustomStyle(),
          child: ConvexAppBar(
            activeColor:Colors.blue.shade900,
            backgroundColor: Colors.white,
            color: Colors.blue.shade900,
            style: TabStyle.fixedCircle,
            items: [
              TabItem(icon: Icons.home, title: 'Home'),
              TabItem(icon: Icons.newspaper, title: 'News'),
              TabItem(
                  icon: Image.asset(
                    "assets/images/logo_box.png",
                    width: 16,
                  ),
                  ),
              TabItem(icon: Icons.notifications, title: 'Inbox'),
              TabItem(icon: Icons.person, title: 'Profile'),
            ],
            onTap: _changeSelectedNavBar,
          ),
        )
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home),
        //       label: 'Beranda',
        //     ),
        //     // BottomNavigationBarItem(
        //     //   icon: Icon(Icons.assignment),
        //     //   label: 'Izin',
        //     // ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.timelapse),
        //       label: 'Riwayat',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.person),
        //       label: 'Akun',
        //     ),
        //   ],
        //   currentIndex: _selectedNavbar,
        //   selectedItemColor: Colors.blue[900],
        //   unselectedItemColor: Colors.grey,
        //   showUnselectedLabels: true,
        //   onTap: _changeSelectedNavBar,
        // ),
        );
  }
}
