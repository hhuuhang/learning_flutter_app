import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bài tập flutter widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

@override
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: const Color.fromARGB(
                                          255, 199, 21, 133),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.tealAccent,
                                      ),
                                    ),
                                  ],
                                )),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.yellow,
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.yellow,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 20,
                  child: Container(
                    color: const Color.fromARGB(255, 199, 21, 133),
                    child: Column(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: Column(),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    color: const Color.fromARGB(255, 199, 21, 133),
                    child: Column(),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Expanded(
                  flex: 5,
                  child: SizedBox(),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: (MediaQuery.of(context).size.width) * 3 / 8,
                    height: (MediaQuery.of(context).size.height) * 3 / 8,
                    color: const Color.fromARGB(149, 96, 125, 139),
                    margin: EdgeInsets.only(
                      // top: (MediaQuery.of(context).size.height) / 2,
                      left: (MediaQuery.of(context).size.width) * 1 / 8,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: SizedBox(),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
