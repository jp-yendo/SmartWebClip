# Smart Web Clip

お気に入りのWebサイトの更新を追跡するためのクロスプラットフォームWeb更新監視アプリケーションです。

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Android%20%7C%20iOS-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

[English README](README.md)

## 機能

### 📋 URL管理
- お気に入りのWebページを追加・整理
- ページタイトルの自動取得
- スマートなサムネイル取得（Open Graph画像、favicon）
- RSSフィードとHTML変更検知をサポート
- URLをコレクションに分類
- 一括操作（コレクションへの追加、削除）

### 🔄 更新チェック
- **RSSモード**: RSS/Atomフィードで新しい記事を監視
- **HTML標準モード**: ページ本文全体の変更を検知
- **HTMLカスタムモード**: CSSセレクタを使用して特定の要素を監視
- 手動および自動更新チェック
- 最終チェック日時と最終更新日時を記録

### 📁 コレクション管理
- URLをコレクションにグループ化して整理
- ドラッグ&ドロップでコレクションの並び替え
- コレクション別または未整理アイテムの表示

### 🌐 多言語対応
- 英語と日本語を標準サポート
- システムの言語設定に従う
- 設定から簡単に言語切り替え可能

### 🎨 モダンなUI
- Material Design 3を採用したクリーンで直感的なインターフェース
- すべての画面サイズに対応したレスポンシブデザイン
- ダークテーマとライトテーマをサポート
- スムーズなアニメーションとトランジション

### 💾 ローカルストレージ
- すべてのデータをSQLiteでローカルに保存
- 外部依存やクラウドサービスは不要
- 高速で効率的なデータベース操作

## スクリーンショット

*(ここにスクリーンショットを追加)*

## インストール

### ビルド済みバイナリのダウンロード

お使いのプラットフォーム向けの最新リリースをダウンロード:
- [Windows](https://github.com/your-repo/releases)
- [macOS](https://github.com/your-repo/releases)
- [Linux](https://github.com/your-repo/releases)
- [Android APK](https://github.com/your-repo/releases)
- iOS: App Storeで提供予定 *(近日公開)*

### ソースからビルド

詳細な手順は [DEVELOPMENT_SETUP.md](Documents/DEVELOPMENT_SETUP.md) を参照してください。

クイックスタート:
```bash
# リポジトリをクローン
git clone https://github.com/your-repo/SmartWebClip.git
cd SmartWebClip

# 依存関係をインストール
flutter pub get

# ローカライゼーションファイルを生成
flutter gen-l10n

# プラットフォームで実行
flutter run -d <device>
```

## 使い方

### URLの追加

1. **+** ボタンをクリック
2. URLを入力
3. （オプション）カスタムタイトルを入力、または自動取得させる
4. 更新チェックタイプを選択:
   - **RSS**: RSSまたはAtomフィードがあるサイト
   - **HTML標準**: 一般的なWebページ
   - **HTMLカスタム**: 特定のページ要素を監視
5. **保存** をクリック

### 更新のチェック

- **手動**: ツールバーの更新ボタンをクリック
- **個別URL**: URL詳細を開いて個別にチェック

### コレクションでの整理

1. **コレクション** タブに移動
2. 新しいコレクションを作成
3. 以下の方法でURLをコレクションに追加:
   - URLリストでの一括選択
   - 個別URLの編集画面

### 言語の変更

1. **設定** タブに移動
2. **言語** をタップ
3. 希望の言語を選択

## システム要件

詳細な要件は [SYSTEM_REQUIREMENTS.md](Documents/SYSTEM_REQUIREMENTS.md) を参照してください。

**最小要件:**
- Windows 10、macOS 10.15、Ubuntu 20.04、Android 5.0、または iOS 12.0
- 4 GB RAM
- 500 MB ストレージ
- インターネット接続

## ドキュメント

- [開発環境のセットアップ](Documents/DEVELOPMENT_SETUP-ja.md) | [English](Documents/DEVELOPMENT_SETUP.md)
- [ビルドとリリースガイド](Documents/BUILD_AND_RELEASE-ja.md) | [English](Documents/BUILD_AND_RELEASE.md)
- [システム要件](Documents/SYSTEM_REQUIREMENTS-ja.md) | [English](Documents/SYSTEM_REQUIREMENTS.md)
- [テストガイド](Documents/TESTING-ja.md) | [English](Documents/TESTING.md)

## 技術スタック

- **フレームワーク**: Flutter 3.0+
- **言語**: Dart
- **データベース**: SQLite (sqflite)
- **状態管理**: Provider
- **HTTPクライアント**: http package
- **HTMLパーサー**: html package
- **RSSパーサー**: webfeed package

## コントリビューション

プルリクエストを歓迎します！

1. リポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを開く

## ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 謝辞

- 素晴らしいフレームワークを提供してくれたFlutterチーム
- コントリビューターとテスター
- オープンソースコミュニティ

## サポート

- **課題**: [GitHub Issues](https://github.com/your-repo/SmartWebClip/issues)
- **ディスカッション**: [GitHub Discussions](https://github.com/your-repo/SmartWebClip/discussions)
- **メール**: support@example.com

## ロードマップ

- [ ] バックグラウンド更新チェック
- [ ] 更新のプッシュ通知
- [ ] エクスポート/インポート機能
- [ ] クラウド同期（オプション）
- [ ] ブラウザ拡張機能との統合
- [ ] 多言語サポートの追加
- [ ] 高度なフィルタリングと検索
- [ ] 更新履歴の追跡

## 変更履歴

バージョン履歴と変更内容については [CHANGELOG.md](CHANGELOG.md) を参照してください。

---

Flutterで ❤️ を込めて作成
