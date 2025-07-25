import 'package:flutter_test/flutter_test.dart';
import 'package:liff_flutter/liff_service.dart';

void main() {
  group('LiffService Tests', () {
    setUp(() {
      LiffService.setTestMode(true);
    });

    tearDown(() {
      LiffService.setTestMode(false);
    });

    test('should return test LIFF ID in test mode', () {
      expect(LiffService.getLiffId(), equals('test-liff-id'));
    });

    test('should initialize successfully in test mode', () async {
      final result = await LiffService.init();
      expect(result, isTrue);
      expect(LiffService.isInitialized(), isTrue);
    });

    test('should handle login state correctly', () {
      expect(LiffService.isLoggedIn(), isFalse);
    });

    test('should return null for profile when not logged in', () {
      expect(LiffService.getProfile(), isNull);
    });

    test('should return null for access token when not logged in', () {
      expect(LiffService.getAccessToken(), isNull);
    });

    test('should return test environment status', () async {
      await LiffService.init();
      final environment = await LiffService.getLiffEnvironment();
      expect(environment, equals('Not Initialized'));
    });

    test('should handle location permission errors', () async {
      // 位置情報機能のテスト（実際の位置情報は取得できないため、エラーハンドリングをテスト）
      final result = await LiffService.getCurrentLocation();
      expect(result, isNotNull);
      // テスト環境では位置情報が取得できないため、エラーまたは null が返される
      if (result != null && result.containsKey('error')) {
        expect(result['error'], isA<String>());
      }
    });
  });
}
