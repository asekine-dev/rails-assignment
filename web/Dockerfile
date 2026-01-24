FROM ruby:3.3

# 必要なOSパッケージ
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libmariadb-dev \
  nodejs

# Rails をインストール
RUN gem install rails

WORKDIR /app