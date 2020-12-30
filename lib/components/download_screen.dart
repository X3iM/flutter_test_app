import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test_app/components/bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadScreen extends StatefulWidget {
  @override
  State createState() => _DownloadScreen();
}

class _DownloadScreen extends State<DownloadScreen> {
  double _downloadPercent;
  double _unarchivePercent;

  bool _downloading;
  String _dir;
  List<String> _images, _tempImages;
  String _path;
  String _localZipFileName = "images.zip";
  String _textMessage = "Downloading...";

  @override
  void initState() {
    super.initState();
    _images = List.empty(growable: true);
    _tempImages = List.empty(growable: true);
    _downloading = false;
    _initDir();
  }

  _initDir() async {
    if (_dir == null) _dir = (await getApplicationDocumentsDirectory()).path;
  }

  Future<File> _downloadFile(String url, String fileName) async {
    var req = await http.Client().get(Uri.parse(url));
    // print(req.body.length);
    // print("download");

    // final request = http.Request('GET', Uri.parse(url));
    // final http.StreamedResponse response = await http.Client().send(request);
    // final contentLength = response.contentLength;
    //
    // setState(() {
    //   _downloadPercent = 0.0;
    // });
    final file = File('$_dir/$fileName');
    // List<int> bytes = [];
    // response.stream.listen((List<int> newBytes) {
    //   bytes.addAll(newBytes);
    //   final downloadedLength = bytes.length;
    //   setState(() {
    //     _downloadPercent = downloadedLength / contentLength;
    //   });
    //   print(_downloadPercent);
    // }, onDone: () async {
    //   setState(() {
    //     _downloadPercent = 0.0;
    //   });
    //   return file.writeAsBytes(bytes);
    // }, onError: (e) => print(e), cancelOnError: true);

    return file.writeAsBytes(req.bodyBytes);
  }

  Future<void> _downloadZip() async {
    setState(() {
      _downloading = true;
    });

    _tempImages.forEach((element) {
      File file = File(element);
      file.delete();
    });

    _images.clear();
    _tempImages.clear();

    // final file = File('$_dir/$_localZipFileName');
    // Dio dio = Dio();
    // http.Response response = (await dio.download(
    //   _path,
    //   file.path,
    //   onReceiveProgress: (count, total) {
    //     print("total: $total");
    //     setState(() {
    //       _downloadPercent = count / total;
    //     });
    //   },
    // )) as http.Response;
    var zippedFile = await _downloadFile(_path, _localZipFileName);
    // print(zippedFile);

    await unarchiveAndSave(zippedFile);

    setState(() {
      _images.addAll(_tempImages);
      _downloading = false;
    });
  }

  unarchiveAndSave(var zippedFile) async {
    final bytes = zippedFile.readAsBytesSync();
    var archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Exception catch (e) {
      setState(() {
        _textMessage = e.toString();
        print(_textMessage);
      });
    }
    // if (archive != null) {
      for (var file in archive) {
        var fileName = '$_dir/${file.name}';
        if (file.isFile) {
          var outFile = File(fileName);
          //print('File:: ' + outFile.path);
          _tempImages.add(outFile.path);
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        }
      }
    // }
  }

  buildList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _images.length,
        itemBuilder: (BuildContext context, int index) {
          return Image.file(
            File(_images[index]),
            fit: BoxFit.fitWidth,
          );
        },
      ),
    );
  }

  progress() {
    return Container(
      child: Expanded(
        child: Container(
          child: Text(_textMessage),
        ),
        // Container(
        //   child: LinearProgressIndicator(
        //     value: _downloadPercent,
        //   ),
        // ),
        // Column(children: [
        //   Container(
        //     child: Text("Unarchive progress"),
        //   ),
        //   Container(
        //     child: LinearProgressIndicator(
        //       value: _unarchivePercent,
        //     ),
        //   ),
        // ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 250,
                  child: TextField(
                    onChanged: (value) {
                      _path = value;
                      // print(_path);
                    },
                  ),
                ),
                FlatButton(
                  color: Colors.blue[200],
                  onPressed: () {
                    setState(() {
                      _textMessage = "Downloading...";
                    });
                    _downloadZip();
                  },
                  child: Icon(
                    Icons.download_sharp,
                    size: 32,
                    color: Colors.blue[600],
                  ),
                )
              ],
            ),
          ),
          if (_downloading) progress(),
          if (_tempImages.length > 0)
            SizedBox(
              height: 42,
              child: Text("Your unarchived images"),
            ),
          Container(
            child: Expanded(
              child: GridView.count(
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  children: List.generate(_tempImages.length, (index) {
                    return Container(
                      child: Card(
                        child: Image.file(
                          File(_tempImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  })),
            ),
          )
        ],
      ),
    );
  }
}
