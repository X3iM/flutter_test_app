import 'dart:convert';

import 'package:flutter_test_app/models/geoname.dart';
import 'package:http/http.dart' as http;

class HttpService {
  final String url = "http://api.geonames.org/searchJSON?name_startsWith=";
  final String endUrl = "&maxRows=30&username=artem12312";

  Future<List<GeoName>> getGeoName(String start) async {
    if (start.isEmpty)
      return null;
    final res = await http.get("$url$start$endUrl");

    if (res.statusCode == 200) {
      final name = jsonDecode(res.body);

      // List<GeoName> geoNames = name["geonames"].map((dynamic e) => GeoName.fromJSON(e)).toList();
      List<GeoName> geoNames = [];
      for (dynamic e in name["geonames"]) {
        geoNames.add(GeoName.fromJSON(e));
      }
      return geoNames;
    } else {
      throw "Can't get geo name.";
    }
  }
}