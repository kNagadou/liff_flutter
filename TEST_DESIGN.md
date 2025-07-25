# テスト設計書

## 概要

LIFF Flutter アプリのテスト実装について説明します。

## テスト構成

### 1. ユニットテスト (`liff_service_test.dart`)

**LiffService** クラスの機能をテストします。

#### テストケース

- ✅ **should return test LIFF ID in test mode**
  - テストモード時にテスト用LIFF IDが返されることを確認

- ✅ **should initialize successfully in test mode**
  - テストモード時に初期化が成功することを確認

- ✅ **should handle login state correctly**
  - ログイン状態の判定が正しく動作することを確認

- ✅ **should return null for profile when not logged in**
  - 未ログイン時にプロフィールがnullであることを確認

- ✅ **should return null for access token when not logged in**
  - 未ログイン時にアクセストークンがnullであることを確認

- ✅ **should return test environment status**
  - テスト環境のステータスが正しく返されることを確認

### 2. ウィジェットテスト (`widget_test.dart`)

**UI コンポーネント** の動作をテストします。

#### テストケース

- ✅ **LIFF Flutter app smoke test**
  - アプリの基本的なUI要素が表示されることを確認
  - タイトル、設定セクション、ボタンの存在確認

- ✅ **LIFF app navigation test**
  - ナビゲーション機能の動作確認
  - LIFFアプリを開くボタンのタップ動作

- ✅ **App displays initialization status**
  - ステータス表示の確認
  - 初期化状態とログイン状態の表示

## テスト環境設定

### テストモード機能

LiffServiceに**テストモード**を実装:

```dart
// テストモードを有効化
LiffService.setTestMode(true);

// デフォルトのテスト用LIFF ID
static const String _liffId = String.fromEnvironment('LIFF_ID', defaultValue: 'test-liff-id');
```

### テストセットアップ (`test_setup.dart`)

```dart
// テスト開始前の設定
static void setUp() {
  LiffService.setTestMode(true);
}

// テスト終了後のクリーンアップ  
static void tearDown() {
  LiffService.setTestMode(false);
}
```

## 実行方法

### ローカル実行

```bash
# 全テスト実行
flutter test

# 詳細レポート付き実行
flutter test --reporter=expanded

# 特定のテストファイル実行
flutter test test/liff_service_test.dart
flutter test test/widget_test.dart
```

### CI/CD実行

GitHub Actionsで自動実行:

```yaml
- name: Run tests
  run: flutter test
```

## カバレッジ測定

```bash
# テストカバレッジ測定（要flutter_test）
flutter test --coverage

# カバレッジレポート生成（要lcov）
genhtml coverage/lcov.info -o coverage/html
```

## モック実装

### LiffService のモック機能

テストモード時の動作:

- **初期化**: 実際のLIFF SDKを使わずに成功を返す
- **LIFF ID**: テスト用の固定値を返す
- **ログイン状態**: false (未ログイン) を返す
- **プロフィール**: null を返す
- **アクセストークン**: null を返す

### テスト時の制約

1. **実際のLINE APIは呼び出されない**
   - LIFFの実機能はテストされない
   - UIとロジックの結合テストのみ

2. **flutter_line_liff パッケージのモック不要**
   - テストモードで迂回するため

3. **環境変数の影響なし**
   - `defaultValue: 'test-liff-id'` で安全

## トラブルシューティング

### よくある問題

1. **テストが失敗する**
   ```
   Expected: exactly one matching candidate
   Actual: _TextWidgetFinder:<Found 0 widgets with text "XXX": []>
   ```
   
   **解決方法**: 実際のUIのテキストを確認して修正

2. **LIFF_ID関連のエラー**
   ```
   Exception: LIFF_ID environment variable is not set
   ```
   
   **解決方法**: `setTestMode(true)` が呼ばれているか確認

3. **Widget初期化のタイムアウト**
   ```
   Test timed out after 30 seconds
   ```
   
   **解決方法**: `pumpAndSettle` の待機時間を調整

## 今後の拡張

### 追加予定のテスト

1. **統合テスト**
   - 実際のLIFF環境での動作テスト
   - `integration_test` パッケージを使用

2. **パフォーマンステスト**
   - レンダリング性能の測定
   - メモリ使用量の監視

3. **アクセシビリティテスト**
   - スクリーンリーダー対応
   - キーボードナビゲーション

### モック機能の拡張

1. **ログイン状態のシミュレーション**
2. **エラー状態のテスト**
3. **ネットワーク状態のモック**
