import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:homework/models/user_model.dart';

const assetKey = 'assets/json/users.json';

class TestParseJson extends StatelessWidget {
  const TestParseJson({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Json Demo')),
      body: const Center(
        child: ElevatedButton(
          onPressed: _readJsonFromAsset,
          child: Text('Read JSON'),
        ),
      ),
    );
  }
}

Future<void> _readJsonFromAsset() async {
  final jsonData = await rootBundle.loadString(assetKey);

  // final decoded = jsonDecode(json);
  // final results = decoded['results'];
  // final firstResult = results[0];
  // final name = firstResult['name'];
  // debugPrint('name=$name');
  final map = jsonDecode(jsonData);
  print(map);
  final users = Results.fromJson(map);
  print('results=$users');
}
