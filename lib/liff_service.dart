import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_line_liff/flutter_line_liff.dart';

class LiffService {
  // LIFF IDを環境変数から取得
  static const String _liffId = String.fromEnvironment(
    'LIFF_ID',
    defaultValue: 'test-liff-id',
  );
  static bool _isInitialized = false;
  static Map<String, dynamic>? _profile;
  static String? _accessToken;
  static FlutterLineLiff? _liff;

  // テスト用フラグ
  static bool _isTestMode = false;

  // テスト用の設定
  static void setTestMode(bool testMode) {
    _isTestMode = testMode;
  }

  // LIFF IDを取得
  static String getLiffId() {
    if (_isTestMode && _liffId == 'test-liff-id') {
      return 'test-liff-id';
    }
    if (_liffId.isEmpty || _liffId == 'test-liff-id') {
      throw Exception('LIFF_ID environment variable is not set');
    }
    return _liffId;
  }

  // LIFF初期化
  static Future<bool> init() async {
    try {
      // テストモードの場合はモック初期化
      if (_isTestMode) {
        _isInitialized = true;
        return true;
      }

      // LIFF IDの存在チェック
      if (_liffId.isEmpty || _liffId == 'test-liff-id') {
        throw Exception('LIFF_ID environment variable is not set');
      }

      // SharedPreferencesから保存された情報を取得
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('liff_access_token');
      final profileJson = prefs.getString('liff_profile');
      if (profileJson != null) {
        _profile = jsonDecode(profileJson);
      }

      // Flutter LINE LIFF の初期化
      _liff = FlutterLineLiff.instance;
      await _liff!.init(
        config: Config(liffId: _liffId, withLoginOnExternalBrowser: true),
        successCallback: () => log('LIFF initialized successfully'),
        errorCallback: (e) => log('errorCallback: $e'),
      );
      _isInitialized = true;

      // ログイン状態を確認
      if (_liff!.isLoggedIn) {
        // 既にログイン済みの場合、プロフィール情報を取得
        await _refreshProfile();
      }

      return true;
    } catch (e, s) {
      log('LIFF初期化エラー: $e', stackTrace: s);
      _isInitialized = false;
      return false;
    }
  }

  // ログイン状態の確認
  static bool isLoggedIn() {
    return _liff?.isLoggedIn ?? false;
  }

  // プロフィール情報を更新
  static Future<void> _refreshProfile() async {
    try {
      if (_liff != null && _liff!.isLoggedIn) {
        final profile = await _liff!.profile;
        final accessToken = _liff!.getAccessToken();

        _profile = {
          'userId': profile.userId,
          'displayName': profile.displayName,
          'statusMessage': profile.statusMessage,
          'pictureUrl': profile.pictureUrl,
        };
        _accessToken = accessToken;

        // SharedPreferencesに保存
        await saveProfile(_profile!, _accessToken!);
      }
    } catch (e) {
      log('プロフィール更新エラー: $e');
    }
  }

  // ユーザープロフィール取得
  static Map<String, dynamic>? getProfile() {
    return _profile;
  }

  // アクセストークン取得
  static String? getAccessToken() {
    return _liff?.getAccessToken() ?? _accessToken;
  }

  // ログイン
  static Future<bool> login() async {
    if (!_isInitialized || _liff == null) {
      throw Exception('LIFF is not initialized. Call init() first.');
    }

    try {
      // LIFF環境内ではinit時に自動ログインされる
      if (_liff!.isInClient) {
        // 既にログイン済みの場合
        if (_liff!.isLoggedIn) {
          await _refreshProfile();
          return true;
        }
        return false;
      } else {
        // 外部ブラウザでのログイン
        _liff!.login();

        // ログインの完了を待つ（ポーリング）
        for (int i = 0; i < 30; i++) {
          await Future.delayed(const Duration(seconds: 1));
          if (_liff!.isLoggedIn) {
            await _refreshProfile();
            return true;
          }
        }
        return false;
      }
    } catch (e) {
      log('ログインエラー: $e');
      return false;
    }
  }

  // ログアウト
  static Future<void> logout() async {
    try {
      // LIFF からログアウト
      _liff?.logout();

      // ローカルデータをクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('liff_access_token');
      await prefs.remove('liff_profile');

      _accessToken = null;
      _profile = null;
    } catch (e) {
      log('ログアウトエラー: $e');
    }
  }

  // プロフィール情報を保存
  static Future<void> saveProfile(
    Map<String, dynamic> profile,
    String accessToken,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('liff_profile', jsonEncode(profile));
      await prefs.setString('liff_access_token', accessToken);

      _profile = profile;
      _accessToken = accessToken;
    } catch (e) {
      log('プロフィール保存エラー: $e');
    }
  }

  // メッセージ送信（LIFF環境では制限があるため、シミュレーション維持）
  static Future<bool> sendMessage(String message) async {
    if (!_isInitialized || _liff == null) {
      throw Exception('LIFF is not initialized. Call init() first.');
    }

    try {
      // LIFFではメッセージ送信APIは限定的
      // 実際の実装では Messaging API を使用する必要があります
      log('メッセージ送信（シミュレーション）: $message');
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      log('メッセージ送信エラー: $e');
      return false;
    }
  }

  // QRコードスキャン
  static Future<String?> scanQrCode() async {
    if (!_isInitialized || _liff == null) {
      throw Exception('LIFF is not initialized. Call init() first.');
    }

    try {
      // QRコードスキャン機能が利用可能かチェック
      if (!_liff!.isApiAvailable(apiName: 'scanCode')) {
        log('QRコードスキャン機能は利用できません');
        return null;
      }

      final result = await _liff!.scanCodeV2();
      return result.value;
    } catch (e) {
      log('QRコードスキャンエラー: $e');
      return null;
    }
  }

  // LIFF画面を閉じる
  static Future<void> closeWindow() async {
    if (!_isInitialized || _liff == null) return;

    try {
      _liff!.closeWindow();
      log('LIFF画面を閉じました');
    } catch (e) {
      log('画面クローズエラー: $e');
    }
  }

  // 初期化状態の確認
  static bool isInitialized() {
    return _isInitialized;
  }

  // LIFF環境の確認
  static Future<String> getLiffEnvironment() async {
    if (!_isInitialized || _liff == null) {
      return 'Not Initialized';
    }

    try {
      if (_liff!.isInClient) {
        return 'LIFF Browser (LINE App)';
      } else {
        return 'External Browser';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
