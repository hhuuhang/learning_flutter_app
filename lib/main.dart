import 'package:flutter/material.dart';
import 'package:homework/pages/TestParseJson.dart';
import 'package:homework/pages/home_work_04.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Homework',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(),
      // home: const TestParseJson(),
      home: const Homework04(),
    );
  }
}
