# LIFF Flutter Sample App

FlutterでLINE LIFF（LINE Front-end Framework）を使用するサンプルアプリケーションです。

このアプリは`flutter_line_liff`パッケージを使用してLIFF機能を実装しています。

## 機能

- LIFF初期化
- LINEユーザーのログイン/ログアウト
- ユーザープロフィール情報の表示
- LINEトークへのメッセージ送信（制限あり）
- QRコードスキャン機能
- ローカルストレージでのユーザー情報保存

## セットアップ

### 1. LINE Developers コンソールでの設定

1. [LINE Developers](https://developers.line.biz/ja/) にアクセス
2. プロバイダーを作成（または既存のものを選択）
3. 新しいチャネルを作成（LINEログインを選択）
4. LIFFタブに移動し、新しいLIFFアプリを追加：
   - LIFFアプリ名: `LIFF Flutter Sample`
   - サイズ: `Full`
   - エンドポイントURL: `https://your-domain.com`
   - Scope: `profile` と `openid` を選択

### 2. 環境変数の設定

このアプリケーションは LIFF_ID を環境変数から取得します。

#### GitHub Secrets の設定（本番環境）

1. GitHubリポジトリの Settings → Secrets and variables → Actions
2. 新しいリポジトリシークレットを追加:
   - Name: `LIFF_ID`
   - Secret: あなたのLIFF ID

#### ローカル開発環境の設定

以下のいずれかの方法でLIFF_IDを設定してください：

**方法1: コマンドライン実行**
```bash
flutter run --dart-define=LIFF_ID=your-liff-id-here
```

**方法2: VS Code デバッグ設定**
VS Codeのデバッグ設定で「liff_flutter (development)」を選択して実行

**方法3: 環境変数ファイル**
プロジェクトルートに `.env` ファイルを作成（Git管理外）：
```
LIFF_ID=your-liff-id-here
```

詳細な設定方法は [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) を参照してください。

### 3. 必要な依存関係

`pubspec.yaml`に以下の依存関係が含まれています：

```yaml
dependencies:
  flutter_line_liff: ^1.0.0+1
  shared_preferences: ^2.2.2
```

## デプロイメント

### GitHub Pages でのデプロイ

このアプリはGitHub Pagesに自動デプロイされます。

#### 設定手順

1. **GitHub Secretsの設定**
   - リポジトリの Settings → Secrets and variables → Actions
   - `LIFF_ID` シークレットを追加

2. **GitHub Pagesの有効化**
   - リポジトリの Settings → Pages
   - Source: "GitHub Actions" を選択

3. **自動デプロイ**
   - `main` ブランチにプッシュすると自動的にビルド・デプロイされます
   - デプロイ状況は Actions タブで確認できます

#### アクセス URL
```
https://knagadou.github.io/liff_flutter/
```

#### デプロイワークフロー
- `.github/workflows/deploy-pages.yml` でビルド・デプロイを自動化
- Flutter Web ビルド（`--base-href /liff_flutter/` 付き）
- GitHub Pages への自動デプロイ

### ローカルでのWebサーバー起動

開発中にローカルでWebサーバーを起動する場合：

```bash
flutter run -d web-server --web-port 8080 --dart-define=LIFF_ID=your-liff-id
```

## 使用方法

1. アプリを起動
2. LIFF IDを入力フィールドに入力
3. "LIFFアプリを開く"ボタンをタップ
4. LIFF画面でログインをタップ（シミュレーション）
5. ログイン後、ユーザー情報が表示される
6. メッセージ送信やQRコードスキャンなどの機能を試用

## ファイル構成

```
lib/
├── main.dart          # メインアプリとホーム画面
├── liff_service.dart  # LIFF機能のシミュレーションサービス
└── liff_page.dart     # LIFF操作画面
```

## 主要機能の説明

### LiffService クラス

- LIFF初期化のシミュレーション
- ログイン状態管理
- ユーザープロフィール管理（サンプルデータ）
- アクセストークン管理
- メッセージ送信のシミュレーション
- QRコードスキャンのシミュレーション
- ローカルストレージとの連携

### LiffPage クラス

- LIFF機能の操作画面
- ユーザー情報の表示
- メッセージ送信インターフェース
- QRコードスキャン機能
- ログイン/ログアウト機能

### MyHomePage クラス

- LIFF IDの設定
- ログイン状態の表示
- ユーザー情報の表示
- アプリの操作インターフェース

## 制限事項

1. **シミュレーション実装**: 実際のLIFF APIではなく、シミュレーションで動作
2. **実機テスト必要**: 実際のLINE環境での動作確認が必要
3. **パッケージの制約**: `flutter_line_liff`パッケージのAPI制約による機能制限

## 実際のLIFF開発について

このサンプルアプリは学習目的のシミュレーションです。実際のLIFF開発では：

1. 正しいLIFF SDKの実装
2. WebViewを使用したLIFF SDK読み込み
3. JavaScript ⇔ Flutter間の通信実装
4. 適切なエラーハンドリング
5. セキュリティ対策

が必要になります。

## トラブルシューティング

### よくある問題

1. **LIFF初期化エラー**
   - LIFF IDが正しいか確認
   - ネットワーク接続を確認

2. **ログインできない**
   - このアプリはシミュレーションのため、実際のLINEログインは行われません

3. **メッセージ送信ができない**
   - シミュレーション実装のため、実際のメッセージ送信は行われません

## 次のステップ

実際のLIFFアプリを開発する場合：

1. WebViewベースの実装を検討
2. LIFF SDK（JavaScript）の直接利用
3. プラットフォーム固有の設定追加
4. 本番環境での動作テスト

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。