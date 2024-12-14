FROM ruby:3.3.6


# 作業ディレクトリの設定
RUN mkdir src
WORKDIR /src

# Gemfile と Gemfile.lock をコピーし、bundlerで依存関係をインストール
COPY ../src/Gemfile /src/Gemfile
COPY ../src/Gemfile.lock /src/Gemfile.lock
RUN bundle install

# アプリケーションコードをコピー
COPY ../src src

# コンテナ起動時に実行させる entrypoint.sh を追加
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Rails サーバ起動
RUN bundle install
CMD ["rails", "server", "-b", "0.0.0.0"]
