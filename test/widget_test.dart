import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_flutter_app/main.dart';

void main() {
  testWidgets('App shows map and chatbot tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(enableNetworkTiles: false));

    expect(find.text('Bản đồ'), findsOneWidget);
    expect(find.text('Chatbot'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);

    await tester.tap(find.text('Chatbot'));
    await tester.pumpAndSettle();

    expect(find.text('Gemini Chat'), findsOneWidget);
    expect(find.text('Gemini API key'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
  });
}
