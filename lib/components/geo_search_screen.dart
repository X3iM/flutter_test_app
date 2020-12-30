import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/components/bottom_nav_bar.dart';
import 'package:flutter_test_app/database/database.dart';
import 'package:flutter_test_app/models/geoname.dart';
import 'package:flutter_test_app/network/http_service.dart';

class GeoSearchScreen extends StatefulWidget {
  @override
  State createState() => _GeoSearchScreenState();
}

class _GeoSearchScreenState extends State<GeoSearchScreen> {
  final HttpService networkService = HttpService();
  Future<List<GeoName>> data;
  List<GeoName> savedGeo = List.empty(growable: true);

  double _heightFactor = 0.65;

  bool showHint = false;

  @override
  void initState() {
    super.initState();
    DBProvider.db
        .getAllGeo()
        .then((value) => setState(() => {savedGeo = value}));
  }

  // ListTile buildItemsForListView(BuildContext context, int index) {
  //   return ListTile(
  //     title: Text(data[index].name, style: TextStyle(fontSize: 20)),
  //     subtitle: Text(data[index].countryName, style: TextStyle(fontSize: 18)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      // resizeToAvoidBottomPadding: false,
      // bottomNavigationBar: BottomNavBar(),
      // child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            // padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    data = networkService.getGeoName(value);
                    if (value.isNotEmpty) _heightFactor = 0.39;
                    else _heightFactor = 0.65;
                  });
                  showHint = value.isEmpty ? false : true;
                },
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Search",
                ),
              ),
            ),
          ),
          // if (showHint == true)
          if (showHint)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: FutureBuilder<List<GeoName>>(
                future: data,
                builder: (context, snapshot) {
                  // if (!showHint) return Container();
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.connectionState == ConnectionState.none &&
                      snapshot.hasData == null) return Container();
                  return Card(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) => InkResponse(
                        onTap: () => setState(() {
                          DBProvider.db.addNewGeo(snapshot.data[index]);
                          savedGeo.insert(0, snapshot.data[index]);
                        }),
                        child: ItemGeo(
                          geoName: snapshot.data[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          SizedBox(
            height: 32,
            child: Text(
              "Your saved Geo",
              style: TextStyle(fontSize: 22),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * _heightFactor,
            alignment: Alignment.bottomCenter,
            // constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            // alignment: Alignment.bottomCenter,
            // height: MediaQuery.of(context).size.height,
            child: Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: savedGeo.length,
                itemBuilder: (BuildContext context, int index) {
                  return ItemGeo(
                    geoName: savedGeo[index],
                  );
                },
                // children: List.generate(savedGeo.length, (index) => ItemGeo(geoName: savedGeo[index],)),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          //   child: Expanded(
          //     child: ListView.builder(
          //       shrinkWrap: true,
          //       itemCount: savedGeo.length,
          //       scrollDirection: Axis.vertical,
          //       itemBuilder: (context, index) => ItemGeo(
          //         geoName: savedGeo[index],
          //       ),
          //     ),
          //   ),
          // ),
        ],
        // ),
      ),
    );
  }
}

class ItemGeo extends StatelessWidget {
  final GeoName geoName;

  const ItemGeo({this.geoName});

  @override
  Widget build(BuildContext context) {
    return Card(
      // child: InkResponse(
      // onTap: () {
      //   DBProvider.db.addNewGeo(geoName);
      //   print("add new goe to DB");
      // },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // alignment: Alignment.center,
            // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
            child: Text(
              "${geoName.name}",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Container(
            // alignment: Alignment.center,
            // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2.0),
            child: Text(
              "${geoName.countryName}",
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
        // ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final GeoName geoName;

  ListItem(this.geoName);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        child: Column(
          children: [
            Text(geoName.name),
            Text(geoName.countryName),
          ],
        ));
  }
}
