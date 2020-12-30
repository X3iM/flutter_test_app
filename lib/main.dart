import 'package:flutter_test_app/components/bottom_nav_bar.dart';
import 'package:flutter_test_app/components/download_screen.dart';
import 'package:flutter_test_app/components/geo_search_screen.dart';
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test_app/models/geoname.dart';
import 'package:flutter_test_app/network/http_service.dart';

void main() => runApp(HomePage());

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
      // title: "Test App",
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => GeoSearchScreen(),
      //   '/download_screen': (context) => DownloadScreen(),
    );
  }
}
