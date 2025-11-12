# 開発環境のセットアップ

## 前提条件

### 1. Flutter SDKのインストール

公式サイトからFlutter SDK（バージョン3.0以降）をダウンロードしてインストールします：
https://flutter.dev/docs/get-started/install

### 2. プラットフォーム固有の要件

#### Windows
- Visual Studio 2022以降と「C++によるデスクトップ開発」ワークロード
- Windows 10以降

#### macOS
- Xcode 14以降
- CocoaPods（インストール方法: `sudo gem install cocoapods`）
- macOS 10.15（Catalina）以降

#### Linux
- CMake
- Ninjaビルドシステム
- GTK開発ライブラリ
- pkg-config

Ubuntu/Debianでのインストール:
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

#### Android
- Android StudioまたはAndroid SDK
- Android SDK Platform-Tools
- Android SDK Build-Tools
- Androidエミュレータ（オプション、テスト用）

#### iOS（macOSのみ）
- Xcode 14以降
- iOS 12.0以降
- CocoaPods

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd SmartWebClip
```

### 2. 依存関係のインストール

```bash
flutter pub get
```

### 3. ローカライゼーションファイルの生成

```bash
flutter gen-l10n
```

### 4. プラットフォーム固有のセットアップ

#### Windows
```bash
flutter config --enable-windows-desktop
```

#### macOS
```bash
flutter config --enable-macos-desktop
cd macos
pod install
cd ..
```

#### Linux
```bash
flutter config --enable-linux-desktop
```

#### Android
Android SDKが適切に設定されていれば、追加のセットアップは不要です。

#### iOS（macOSのみ）
```bash
cd ios
pod install
cd ..
```

## アプリケーションの実行

### デスクトップ（Windows、macOS、Linux）
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### モバイル（Android、iOS）
```bash
# Android
flutter run -d android

# iOS（macOSのみ）
flutter run -d ios
```

### 利用可能なデバイスの一覧表示
```bash
flutter devices
```

## 本番環境用のビルド

詳細なビルド手順については、[BUILD_AND_RELEASE-ja.md](./BUILD_AND_RELEASE-ja.md)を参照してください。

## トラブルシューティング

### Flutter Doctor
開発環境を確認するには、以下のコマンドを実行します：
```bash
flutter doctor -v
```

### よくある問題

1. **"No devices found"（デバイスが見つかりません）**
   - ターゲットプラットフォームが有効になっているか確認
   - モバイルの場合、エミュレータ/デバイスが接続されているか確認
   - デスクトップの場合、プラットフォーム固有の要件を確認

2. **"pub get failed"（pub getが失敗しました）**
   - インターネット接続を確認
   - `flutter pub cache repair`を実行してみる

3. **ビルドエラー**
   - ビルドをクリーン: `flutter clean`
   - 依存関係を再インストール: `flutter pub get`
   - 必要に応じてプラットフォームファイルを再生成

## IDEのセットアップ

### Visual Studio Code
1. Flutter拡張機能をインストール
2. Dart拡張機能をインストール
3. プロジェクトフォルダを開く
4. F5キーを押して実行

### Android Studio / IntelliJ IDEA
1. Flutterプラグインをインストール
2. Dartプラグインをインストール
3. プロジェクトを開く
4. デバイスを選択して実行ボタンをクリック

## コード生成

モデルクラスを変更したり、新しいローカライゼーションを追加した場合：

```bash
# ローカライゼーションファイルの生成
flutter gen-l10n

# クリーンして再ビルド
flutter clean
flutter pub get
```
