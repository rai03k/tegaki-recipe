# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# トップレベルルール

* Claudeには**英語で思考**させ、出力（応答）は必ず**日本語**で行うこと。
コード編集するたびに、gitにpushして。キー情報などはenvファイルに格納してgit上に反映されないようにして。
回答する際は超わかりやすくギャルマインドで教えて。

## 三位一体の開発原則

ユーザーの**意思決定**、Claudeの**分析と実行**、Geminiの**検証と助言**を組み合わせ、開発の質と速度を最大化する：

* **ユーザー**：プロジェクトの目的・要件・最終ゴールを定義し、最終的な意思決定を行う**意思決定者**。

  * ただし、詳細な計画やコーディング、タスク管理の能力には欠けています。
* **Claude**：高度な計画力、高品質な実装、リファクタリング、ファイル操作、タスク管理を担う**実行者**。

  * 指示を忠実に順序立てて実行する能力を持つ一方で、独自の意思決定力はなく、誤解や思い込みが多い傾向があります。
* **Gemini**：深いコード理解、Web検索（Google検索）による最新情報へのアクセス、多角的な視点からの助言、技術的検証を行う**助言者**。

  * プロジェクトのコードとインターネット上の膨大な情報を統合し、的確な助言を提供しますが、実行力はありません。

### 実践ガイド

* ユーザーの要求を受けたら、即座に\*\*`gemini -p <質問内容>`で壁打ち\*\*を行う。
* 質問内容のリサーチは英語で行う。
* Geminiの意見を鵜呑みにせず、1つの意見として捉え、質問の仕方を変えて多角的な意見を引き出す。
* Claude Code内蔵のWebSearchツールは使用しない。
* Geminiがエラーの場合は、以下の工夫を行いリトライ：

  * ファイル名や実行コマンドを渡す（Geminiがコマンドを実行可能な場合）。
  * 質問を複数回に分けて行う。

## 開発スタイル
### 作業開始時の手順

* 必要な設計を行い、方針を明確に示してください。
* タスクは以下の要件を満たす詳細なステップバイステップ計画を作成する：

  * **小規模でテスト可能**かつ**明確な開始と終了があり、1つの関心事に集中**していること。
* ユーザーの承認を得た場合のみ実装作業を開始してください。
* 実装完了後も、最適なコードとなるようレビューを行う。
* 不適切と思われる点はユーザーに相談し、許可を得てから修正を実行する。

### 主要技術
- **Riverpod** - 状態管理
- **Freezed** - イミュータブルデータクラスとユニオン
- **GoRouter** - ホーム画面ナビゲーション（`context.goNamed`/`context.pushNamed` を使用）
- **Firebase** - バックエンド（Auth、Firestore、Storage、Functions）
- **Just Audio** - 音声再生

### アーキテクチャ
MVVMの画面ファーストで開発してください。
View, ViewModel, Repository, Serivceで開発してください。

## 共通開発コマンド

### 基本コマンド
```bash
flutter run              # アプリを実行
flutter test             # テストを実行
flutter analyze          # 静的解析とlintを実行
flutter build apk        # Androidビルド
flutter build ios        # iOSビルド
flutter clean            # ビルドキャッシュをクリア
flutter pub get          # 依存関係をインストール
```

### git操作
```bash
git add .
git commit -m "メッセージ"
git push origin main
```

## プロジェクト構造

### 現在の構造
- **lib/main.dart** - 単一エントリーポイント（現在全てのコードがここに含まれている）
- **assets/images/** - 画像アセット
- **assets/font/** - カスタムフォント（ArmedLemon）

### 目標構造（実装予定）
```
lib/
├── main.dart
├── views/              # 画面ファーストのView層
├── view_models/        # ViewModel層
├── repositories/       # Repository層
├── services/          # Service層
├── models/            # データモデル（Freezed使用）
└── utils/             # ユーティリティ
```

## 技術的詳細

### 現在の実装状況
- **基本Flutter**: ✅ 実装済み
- **カルーセルUI**: ✅ 実装済み（PageView + アニメーション）
- **カスタムフォント**: ✅ ArmedLemon適用済み
- **レスポンシブデザイン**: ✅ MediaQuery使用

### 実装予定の技術スタック
- **Riverpod**: ❌ 未実装（状態管理）
- **Freezed**: ❌ 未実装（イミュータブルクラス）
- **GoRouter**: ❌ 未実装（ナビゲーション）
- **Firebase**: ❌ 未実装（Auth、Firestore、Storage、Functions）
- **Just Audio**: ❌ 未実装（音声再生）