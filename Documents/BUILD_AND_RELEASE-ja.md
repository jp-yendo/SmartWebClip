# ビルドとリリースガイド

## 本番環境用のビルド

### Windows

#### 1. リリースバージョンのビルド
```bash
flutter build windows --release
```

出力先: `build/windows/runner/Release/`

#### 2. インストーラの作成（オプション）
Inno SetupまたはNSISを使用してインストーラパッケージを作成できます。

Inno Setupの使用例:
1. Inno Setupをインストール: https://jrsoftware.org/isinfo.php
2. `.iss`スクリプトファイルを作成
3. インストーラをコンパイル

#### 3. 配布
- `Release`フォルダ全体をZIPファイルとして配布、または
- インストーラパッケージを作成

---

### macOS

#### 1. リリースバージョンのビルド
```bash
flutter build macos --release
```

出力先: `build/macos/Build/Products/Release/`

#### 2. コード署名（配布に必須）
```bash
# アプリに署名
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (Team ID)" \
  "build/macos/Build/Products/Release/Smart Web Clip.app"

# 署名を検証
codesign --verify --deep --verbose=2 \
  "build/macos/Build/Products/Release/Smart Web Clip.app"
```

#### 3. DMGの作成（オプション）
`create-dmg`または類似のツールを使用してDMGインストーラを作成します。

#### 4. 公証（macOS 10.15+で必須）
Appleに公証のためアプリを提出:
```bash
# アプリのZIPを作成
ditto -c -k --keepParent \
  "build/macos/Build/Products/Release/Smart Web Clip.app" \
  SmartWebClip.zip

# 公証のため提出
xcrun altool --notarize-app \
  --primary-bundle-id "com.example.smartwebclip" \
  --username "your-apple-id@example.com" \
  --password "@keychain:AC_PASSWORD" \
  --file SmartWebClip.zip
```

#### 5. 配布
- Mac App Store、または
- Webサイトから直接ダウンロード

---

### Linux

#### 1. リリースバージョンのビルド
```bash
flutter build linux --release
```

出力先: `build/linux/x64/release/bundle/`

#### 2. パッケージの作成

##### Snapパッケージ
```bash
# snapcraftをインストール
sudo snap install snapcraft --classic

# snapを作成
snapcraft
```

##### AppImage
`appimagetool`を使用してAppImageパッケージを作成します。

##### Flatpak
Flatpakマニフェストを作成し、`flatpak-builder`でビルドします。

#### 3. 配布
- Snap Store
- Flathub
- tarballとして直接ダウンロード

---

### Android

#### 1. 署名の設定

`android/key.properties`を作成:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore>
```

キーストアを生成:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

#### 2. APKのビルド
```bash
flutter build apk --release
```

出力先: `build/app/outputs/flutter-apk/app-release.apk`

#### 3. App Bundleのビルド（Google Play用）
```bash
flutter build appbundle --release
```

出力先: `build/app/outputs/bundle/release/app-release.aab`

#### 4. 配布
- Google Play Store
- APKの直接ダウンロード
- サードパーティアプリストア

---

### iOS

#### 1. 署名の設定
1. Xcodeで`ios/Runner.xcworkspace`を開く
2. Runnerプロジェクトを選択
3. Signing & Capabilitiesに移動
4. 開発チームを選択
5. プロビジョニングプロファイルを設定

#### 2. リリースビルド
```bash
flutter build ios --release
```

#### 3. アーカイブの作成
1. Xcodeを開く
2. Product → Archive
3. アーカイブが完了するまで待機

#### 4. App Storeへのアップロード
1. Xcode Organizerでアーカイブを選択
2. "Distribute App"をクリック
3. "App Store Connect"を選択
4. ウィザードに従う

#### 5. 配布
- App Storeのみ（iOSは一般ユーザーのサイドローディングを許可していません）

---

## バージョン管理

### バージョン番号の更新

`pubspec.yaml`を編集:
```yaml
version: 1.0.0+1
```

形式: `major.minor.patch+build`

### リリースノートの生成

各バージョンのリリースノートをストアリストまたはリリースページに作成します。

---

## リリース前のテスト

1. **機能テスト**
   - すべての機能をテスト
   - 異なる画面サイズでテスト
   - ロケール切り替えをテスト

2. **パフォーマンステスト**
   - メモリ使用量を確認
   - 起動時間を確認
   - 大量のデータセットでテスト

3. **プラットフォーム固有のテスト**
   - サポートする最小OSバージョンでテスト
   - 最新OSバージョンでテスト

---

## ストア要件

### Google Play Store
- プライバシーポリシーのURL
- アプリアイコン（512x512 PNG）
- フィーチャーグラフィック（1024x500 PNG）
- スクリーンショット（最低2枚）
- コンテンツレーティングアンケート
- ターゲットAPIレベル33+（Android 13+）

### Apple App Store
- プライバシーポリシーのURL
- アプリアイコン（1024x1024 PNG）
- サポートするすべてのデバイスサイズのスクリーンショット
- App Storeの説明
- キーワード
- 年齢制限

### Microsoft Store（Windows）
- プライバシーポリシーのURL
- アプリアイコン（さまざまなサイズ）
- スクリーンショット
- 年齢制限
- コンテンツ記述子

---

## 継続的インテグレーション

自動ビルドのためCI/CDのセットアップを検討してください：
- GitHub Actions
- GitLab CI/CD
- Bitrise
- Codemagic

GitHub Actionsのワークフロー例: `.github/workflows/build.yml`を参照
