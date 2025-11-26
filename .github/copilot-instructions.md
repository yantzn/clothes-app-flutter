# Copilot 指示ファイル（Flutter 服装提案アプリ）

このファイルは GitHub Copilot に対して、
Flutter アプリを開発する際の **アーキテクチャ・コーディング規約・生成ルール** を明示するための設定文書です。

Copilot はこの方針に従ってコードを生成してください。

---

# 🎯 アプリ概要

本アプリは、気温・湿度・体感温度などの気象データをもとに
**子どもの服装を提案** し、必要に応じて **楽天アフィリエイト商品** を提示する。

機能は以下：

- 今日の天気の取得と表示
- 気温に応じた服装提案ロジック
- 週間予報の表示
- プロファイル管理（住まい・生年月日）
- 楽天 API による商品表示

---

# 🏛 アーキテクチャ

## 1. ディレクトリ構成（feature-first + Clean Architecture）

```
lib/
 ├── main.dart
 ├── app/
 │   ├── app.dart
 │   ├── router.dart
 │   └── theme.dart
 ├── core/
 │   ├── error/
 │   │   └── failures.dart
 │   ├── network/
 │   │   └── api_client.dart
 │   ├── util/
 │   │   └── converters.dart
 │   └── widgets/
 │       └── app_loading.dart
 └── features/
      ├── weather/
      │   ├── data/
      │   │   ├── datasources/weather_remote_data_source.dart
      │   │   ├── models/weather_dto.dart
      │   │   └── repositories/weather_repository_impl.dart
      │   ├── domain/
      │   │   ├── entities/weather.dart
      │   │   ├── repositories/weather_repository.dart
      │   │   └── usecases/get_today_weather.dart
      │   └── presentation/
      │       ├── providers/weather_providers.dart
      │       └── pages/today_weather_page.dart
      │
      ├── outfit/
      │   ├── data/
      │   │   ├── datasources/rakuten_remote_data_source.dart
      │   │   ├── models/outfit_suggestion_dto.dart
      │   │   └── repositories/outfit_repository_impl.dart
      │   ├── domain/
      │   │   ├── entities/outfit_suggestion.dart
      │   │   ├── repositories/outfit_repository.dart
      │   │   └── usecases/get_outfit_suggestion.dart
      │   └── presentation/
      │       ├── providers/outfit_providers.dart
      │       └── pages/outfit_suggestion_page.dart
      │
      └── profile/
          ├── data/
          ├── domain/
          └── presentation/pages/profile_page.dart
```

---

# 🧭 層の責務

## ■ data 層

- API 呼び出し（RemoteDataSource）
- DTO（外部データ専用モデル）
- Repository 実装（domain の interface を満たす）

Copilot は data 層に UI ロジックを書かないこと。

---

## ■ domain 層

- 純粋な Entity
- Repository interface（抽象）
- UseCase（1 ユースケース 1 クラス）

Copilot は domain 層に HTTP 処理・状態管理・UI を書かないこと。

---

## ■ presentation 層

- Flutter UI（Page / Widget）
- Riverpod Provider
- 状態管理（StateNotifier / AsyncNotifier）

Copilot は presentation 層にビジネスロジックを書かず、UseCase を通すこと。

---

# 🔧 状態管理（Riverpod）

Copilot の生成ルール：

- 依存は `Provider` で注入する
- UI は `ref.watch()` で状態を購読
- 副作用・ロジックは `StateNotifier` / `AsyncNotifier` に寄せる
- `Notifier` 内で UseCase を呼び出す

---

# 🔗 依存関係ルール（重要）

- presentation → domain → data の **一方向のみ**
- domain はどこにも依存しない
- data は domain に依存してよい
- UI と API クライアントを混ぜない

---

# 🧪 テスト方針

Copilot はテストコードを生成する際、以下を守る：

- UseCase は単体テスト可能に（pure logic）
- Repository は mockable にする（interface → impl）
- Provider は状態遷移（loading → data → error）をテストする
- DTO パースのテストを必ず用意する

---

# ✏️ コーディング規約

- 変数名は `lowerCamelCase`
- クラス名は `UpperCamelCase`
- ファイル名は `snake_case.dart`
- UI は StatelessWidget を基本とする
- コメントは日本語で問題なし
- Theme（色・フォント）は app/theme.dart に集約する
- UI にロジックを書かない

---

# 🧰 Copilot への依頼テンプレート

### ■ UseCase の生成依頼例

```
features/weather/domain/usecases/get_today_weather.dart を作成してください。
- WeatherRepository をコンストラクタで受け取る
- call() で Future<Weather> を返す
- 失敗時は Failure を返す Either 型を使用する
```

### ■ Provider 作成依頼

```
features/outfit/presentation/providers/outfit_providers.dart を作成。
UseCase を呼び出し、AsyncNotifier で状態管理してください。
```

### ■ 画面コードの生成

```
features/weather/presentation/pages/today_weather_page.dart を生成してください。
- todayWeatherProvider を watch して表示
- 気温・湿度・風速を表示
- 読み込み中は CircularProgressIndicator
```

---

# 🚦 注意点（Copilot 向け）

- UI にビジネスロジックを埋め込まない
- DTO と Entity を混ぜてはいけない
- Repository interface を飛ばして DataSource を直接呼ばない
- Provider の中で直接 HTTP を叩かない
- UseCase を bypass しないこと

---

# 🔚 完了

Copilot は上記のアーキテクチャと規約に従ってコード生成・補完を行うこと。
