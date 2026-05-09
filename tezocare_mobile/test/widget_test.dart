import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/auth/presentation/pages/splash_page.dart';

void main() {
  testWidgets('SplashPage shows TezoCare text and loading indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));
    expect(find.text('TezoCare'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
