import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test layout 3', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [DataColumn(label: Text('A'))],
                rows: const [],
              )
            )
          ]
        )
      )
    ))));
  });
}
