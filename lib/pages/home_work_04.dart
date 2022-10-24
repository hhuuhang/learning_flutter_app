import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class Homework04 extends StatefulWidget {
  const Homework04({Key? key}) : super(key: key);

  @override
  _Homework04State createState() => _Homework04State();
}

class _Homework04State extends State<Homework04> {
  var imageUrl =
      "https://svs.gsfc.nasa.gov/vis/a030000/a030800/a030877/frames/5760x3240_16x9_01p/BlackMarble_2016_1200m_africa_s_labeled.png";
  bool downloading = true;
  String downloadingStr = "";
  String savePath = "";
  double size = 250;
  double percent = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Download File"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Center(
            child: downloading
                ? SizedBox(
                    height: size,
                    width: size,
                    child: const Card(
                      color: Colors.pink,
                      child: Center(
                        child: Text(
                          "No data !!!",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: size,
                    width: size,
                    child: Center(
                      child: Image.file(
                        File(savePath),
                        height: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
          ),
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: (percent == 0)
                  ? const SizedBox(
                      height: 70,
                    )
                  : SizedBox(
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Center(
                            child: Text(
                              downloadingStr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: percent,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xff00ff00)),
                                backgroundColor: const Color(0xffD6D6D6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: downloadFile,
                child: const Text('Download'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future downloadFile() async {
    try {
      final dio = Dio();

      final fileName = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
      debugPrint(fileName);

      savePath = await getFilePath(fileName);

      await dio.download(imageUrl, savePath, onReceiveProgress: (rec, total) {
        final per = ((rec / total) * 100).toStringAsFixed(1);
        final percents = (rec / total) * 100;

        if (percents < 100) {
          setState(() {
            percent = (rec / total);
            downloading = true;
            // download = (rec / total) * 100;
            downloadingStr = "Downloading Image : $per %";
          });
        } else {
          setState(() {
            downloading = false;
            downloadingStr = "Completed: 100%";
            showToast();
          });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    final dir = await getApplicationDocumentsDirectory();

    path = '${dir.path}/$uniqueFileName';

    return path;
  }

// Show Toast in bottom of the screen when downloaded image
  showToast() {
    Fluttertoast.showToast(
      msg: "The image is downloaded",
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
