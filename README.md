# 写真管理アプリケーション（OAuth連携・ツイート機能付き）

写真のアップロード・一覧表示と、外部連携アプリケーションへのツイート投稿を行う
簡易的な Web アプリケーションです。

---

## 概要

- セッションを用いたログイン認証
- ログインユーザーごとの写真管理（一覧表示・アップロード）
- OAuth 認可による外部アプリケーション連携
- 写真タイトルと画像URLを用いたツイート投稿機能

課題要件に基づき、必要な機能をシンプルに実装しています。

---

## 動作環境

- Ruby 3.3.10 / Ruby on Rails 8.1.2
- MySQL 8.0.45
- Docker / Docker Compose

---

## 起動手順

### 1. コンテナ外での作業

```bash
# リポジトリをクローン
git clone https://github.com/asekine-dev/rails-assignment.git
cd rails-assignment

# 環境変数ファイルを作成
# ------------------------------------------------
# .env に OAuth 認証に必要な値を設定してください。
#（公開リポジトリのため、値は手動入力形式としています）
#
# .env を変更した場合、コンテナ再作成が必要なため  
# `docker compose up -d`（必要に応じて `--force-recreate`）を再実行してください。
# ------------------------------------------------
cp .env.example .env

# コンテナ起動
docker compose up -d

# コンテナ確認（以下名称のコンテナが表示されること）
# - rails-assignment-db-1
# - rails-assignment-web-1
docker compose ps

# Railsコンテナに入る
# ------------------------------------------------
# 環境によってコンテナ名が異なる場合があります。
# その場合は `docker compose ps` の結果に表示されている Rails コンテナ名を指定してください。
# ------------------------------------------------
docker exec -it rails-assignment-web-1 bash
```

### 2. コンテナ内での作業
```bash
cd myapp
bundle install
bin/rails db:migrate

# 写真一覧確認用のサンプルデータを登録します。
bin/rails db:seed

bin/rails s -b 0.0.0.0
```

### 3. ブラウザでアクセス
```
http://localhost:3000
```

---

## 初期ログインユーザー

以下のユーザーが seed データとして登録されています。

- 1人目
  - Email: user1@example.com
  - Password: password1

- 2人目（他ユーザの登録情報が見えないことを確認する用）
  - Email: user2@example.com
  - Password: password2

---

## 実装方針について

要件を増やさない範囲で、安全性・事故防止の観点から以下の対応を行っています。

- 写真アップロード時に画像ファイル以外が登録されないよう、content type のチェックを追加
  - これは新たな仕様追加ではなく、「現状の要件を安全に満たすための最小限の防御」として実装しました。

---

## 使用しているGemについて

- 基本的に rails new 時点の Gemfile を維持しています
- テスト用途として minitest-mock のみ追加しています
  - 理由：
    - Minitest 6 以降では stub 機能が minitest-mock に分離されたため

---

## 今回は実装しなかったが、実務であれば検討したい点

課題要件外のため実装は行っていませんが、
実業務であれば以下の仕様は事前に定義したいと考えました。

- ユーザーごとの写真アップロード可能枚数
- アップロード可能な画像サイズの上限
- パスワードの許容文字種（半角/全角など）

想定外のエラーや運用上の問題を防ぐため、
仕様として明確にした上で実装するのが望ましいと考えています。

---

## 作成にかかった時間

約35時間程度

内訳には以下の作業も含まれています。

- WSL + Docker 環境の構築
- GitHub Actions（CI）の設定
- README 作成および提出準備

---

## AIツールの利用について

本課題では AI ツールを利用しています。
- コード生成や設計の補助として使用
- 生成されたコードはすべて内容を確認し、動作検証を行っています

---

## テストの実行方法

前提：リポジトリルートにて、`docker compose up -d` を実施済とします

### 1. コンテナ外での作業

```bash
# Railsコンテナに入る
docker exec -it rails-assignment-web-1 bash
```

### 2. コンテナ内での作業

```bash
cd myapp
# 全テストケース実施
bin/rails test
```

---

## 動作確認環境

- OS: Windows 10 + WSL2 (Ubuntu)
- Browser: Chrome 144.0.7559.110
- Docker Desktop 29.1.3