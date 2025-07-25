# GitHub Pages デプロイメント設定

このドキュメントでは、LIFF Flutter アプリを GitHub Pages にデプロイする手順を説明します。

## 🚀 自動デプロイの仕組み

1. **トリガー**: `main` ブランチへのプッシュ時
2. **ビルド**: Flutter Web アプリの自動ビルド
3. **デプロイ**: GitHub Pages への自動デプロイ

## ⚙️ セットアップ手順

### 1. GitHub Secrets の設定

リポジトリに必要なシークレットを設定します：

1. GitHubリポジトリにアクセス
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** をクリック
4. 以下のシークレットを追加：
   - **Name**: `LIFF_ID`
   - **Secret**: あなたのLIFF ID（例: `2007733449-eKPDM4bM`）

### 2. GitHub Pages の有効化

1. リポジトリの **Settings** → **Pages** に移動
2. **Source** で "**GitHub Actions**" を選択
3. 設定を保存

### 3. ワークフローファイルの確認

以下のファイルが正しく配置されていることを確認：

- `.github/workflows/deploy-pages.yml` - GitHub Pages デプロイワークフロー
- `.github/workflows/build.yml` - ビルド・テストワークフロー

## 📁 ファイル構成

```
.github/
  workflows/
    deploy-pages.yml  # GitHub Pages デプロイ
    build.yml         # ビルド・テスト
web/
  index.html         # メタデータ更新済み
  manifest.json      # PWA設定（LINE用）
  404.html          # SPA用404ハンドリング
```

## 🌐 アクセス URL

デプロイ後、以下のURLでアクセス可能：

```
https://knagadou.github.io/liff_flutter/
```

## 🔧 ローカル開発

### Web サーバーでの起動

```bash
# 開発用サーバー起動
flutter run -d web-server --web-port 8080 --dart-define=LIFF_ID=your-liff-id

# プロダクション ビルド（GitHub Pages設定）
flutter build web --base-href /liff_flutter/ --dart-define=LIFF_ID=your-liff-id
```

### VS Code での起動

`.vscode/launch.json` の設定を使用：

- **liff_flutter (development)** - 固定LIFF IDで起動
- **liff_flutter (prompt for LIFF_ID)** - LIFF IDを入力して起動
- **web-server** - Webサーバーとして起動

## 📋 デプロイ状況の確認

1. GitHubリポジトリの **Actions** タブを確認
2. 最新のワークフロー実行状況を確認
3. エラーがある場合はログを確認

## 🚨 トラブルシューティング

### よくある問題

1. **LIFF_ID シークレットが設定されていない**
   - エラー: `LIFF_ID environment variable is not set`
   - 解決: GitHub Secrets で `LIFF_ID` を設定

2. **base-href の問題**
   - リソースが404で読み込めない
   - `--base-href /liff_flutter/` が正しく設定されているか確認

3. **GitHub Pages が有効になっていない**
   - リポジトリ Settings → Pages で "GitHub Actions" を選択

### デバッグ方法

```bash
# ローカルでGitHub Pages設定をテスト
flutter build web --base-href /liff_flutter/ --dart-define=LIFF_ID=test-id

# ビルド結果をローカルサーバーで確認
cd build/web
python -m http.server 8000
# http://localhost:8000 でアクセス
```

## 🔄 継続的デプロイメント

- **main** ブランチにプッシュで自動デプロイ
- プルリクエストでビルドテスト実行
- エラー時はメール通知（GitHubアカウント設定による）

## 📱 LIFF設定

GitHub Pages にデプロイした後：

1. LINE Developers Console でLIFFアプリを作成
2. **エンドポイントURL** を設定:
   ```
   https://knagadou.github.io/liff_flutter/
   ```
3. **Scope**: `profile` と `openid` を選択
4. LIFF ID を GitHub Secrets に設定

## 🔐 セキュリティ

- LIFF ID は GitHub Secrets で管理
- ソースコードには機密情報を含まない
- 環境変数による設定管理
