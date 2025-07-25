# 開発環境での実行方法

## 環境変数の設定

このアプリケーションは LIFF_ID を環境変数から取得します。

### 1. GitHub Secrets の設定

GitHub リポジトリで以下のsecretを設定してください：

- `LIFF_ID`: あなたのLIFF ID（例: 2007733449-yeav9Nz9）

Settings → Secrets and variables → Actions → New repository secret

### 2. ローカル開発での実行

#### 方法1: コマンドラインで環境変数を指定

```bash
flutter run --dart-define=LIFF_ID=your-liff-id-here
```

#### 方法2: VS Code での設定

`.vscode/launch.json` を作成して以下を設定：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter (Development)",
            "request": "launch",
            "type": "dart",
            "toolArgs": [
                "--dart-define=LIFF_ID=your-liff-id-here"
            ]
        }
    ]
}
```

#### 方法3: 環境変数ファイルの使用

プロジェクトルートに `.env` ファイルを作成（Git には含めない）：

```
LIFF_ID=your-liff-id-here
```

### 3. ビルド時の環境変数指定

#### Web ビルド
```bash
flutter build web --dart-define=LIFF_ID=your-liff-id-here
```

#### Android ビルド
```bash
flutter build apk --dart-define=LIFF_ID=your-liff-id-here
```

#### iOS ビルド
```bash
flutter build ios --dart-define=LIFF_ID=your-liff-id-here
```

## 注意事項

- LIFF_ID が設定されていない場合、アプリケーションは起動時にエラーを表示します
- 本番環境では必ず GitHub Secrets を使用してください
- ローカルでの開発時は、実際のLIFF IDを使用してください
