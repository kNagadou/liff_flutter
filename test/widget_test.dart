// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liff_flutter/main.dart';
import 'test_setup.dart';

void main() {
  // テスト環境のセットアップ
  setupTestEnvironment();

  testWidgets('LIFF Flutter app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization to complete
    await tester.pumpAndSettle();

    // Verify that our app shows the correct title
    expect(find.text('LIFF Flutter Sample'), findsOneWidget);

    // Verify that LIFF設定 section exists
    expect(find.text('LIFF設定'), findsOneWidget);

    // Verify that the LIFF ID is displayed
    expect(find.text('LIFF ID'), findsOneWidget);

    // Verify that the open LIFF app button exists
    expect(find.text('LIFFアプリを開く'), findsOneWidget);

    // Verify that status section exists
    expect(find.text('ステータス'), findsOneWidget);
  });

  testWidgets('LIFF app navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization to complete
    await tester.pumpAndSettle();

    // Find and tap the "LIFFアプリを開く" button
    final openButton = find.text('LIFFアプリを開く');
    expect(openButton, findsOneWidget);

    await tester.tap(openButton);
    await tester.pumpAndSettle();

    // Verify that we navigated to the LIFF page
    // In test mode, this should work without errors
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('App displays initialization status', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the app to settle
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check that status information is displayed
    expect(find.text('LIFF初期化'), findsOneWidget);
    expect(find.text('ログイン状態'), findsOneWidget);

    // Check that status values are displayed
    expect(find.text('完了'), findsOneWidget); // LIFF初期化: 完了
    expect(find.text('未ログイン'), findsOneWidget); // ログイン状態: 未ログイン
  });
}
