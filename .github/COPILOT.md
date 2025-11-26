# Copilot プロジェクトガイド（Flutter 服装提案アプリ）

このプロジェクトは Flutter で構築された「子ども向け服装提案アプリ」です。

## 📌 アーキテクチャ
- feature-first 構造
- Clean Architecture（data / domain / presentation）
- 状態管理は Riverpod（Provider / StateNotifier / AsyncNotifier）
- UI は StatelessWidget を基本とし、ロジックは UseCase に寄せる

## 📌 依存関係
- presentation → domain → data の単方向
- domain 層は純粋なロジックのみ（UI・HTTP禁止）
- data 層には API 呼び出しのみ
- UI は provider を watch して状態を購読

## 📌 生成してほしいファイル
- UseCase（1ユースケース1ファイル）
- Repository（抽象 + 実装）
- DataSource（API呼び出し）
- Provider（StateNotifier / AsyncNotifier）
- Page / Screen（UIはロジックを持たない）

## 📌 避けてほしい生成
- UI にビジネスロジックを書く
- domain 層に HTTP コードを書く
- Repository を介さずに DataSource を直接呼ぶ
- Provider 内で副作用を実行する
- DTO と Entity を混ぜる

## 📌 命名規則
- クラス名: UpperCamelCase
- 変数名: lowerCamelCase
- ファイル名: snake_case.dart
- ディレクトリ名: feature 単位

## 📌 参考ディレクトリ構成
lib/features/weather/
 ├── data/
 ├── domain/
 └── presentation/

## 📌 目的
Copilot がこのプロジェクトのアーキテクチャに従って、
一貫性のあるコード補完・生成を行うためのガイドです。
