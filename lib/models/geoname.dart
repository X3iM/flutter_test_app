import 'package:flutter/cupertino.dart';

class GeoName {
  final String name;
  final String countryName;

  GeoName({@required this.name, @required this.countryName});

  factory GeoName.fromJSON(Map<String, dynamic> json) {
    return GeoName(name: json["name"], countryName: json["countryName"]);
  }

  Map<String, dynamic> toJSON() => {"name": name, "countryName": countryName};
}
