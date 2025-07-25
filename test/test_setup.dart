import 'package:flutter_test/flutter_test.dart';
import 'package:liff_flutter/liff_service.dart';

/// テスト用のセットアップユーティリティ
class TestSetup {
  /// テスト開始前のセットアップ
  static void setUp() {
    // LiffServiceをテストモードに設定
    LiffService.setTestMode(true);
  }

  /// テスト終了後のクリーンアップ
  static void tearDown() {
    // テストモードを無効化
    LiffService.setTestMode(false);
  }
}

/// テスト用のグループセットアップ
void setupTestEnvironment() {
  setUpAll(() {
    TestSetup.setUp();
  });

  tearDownAll(() {
    TestSetup.tearDown();
  });
}
