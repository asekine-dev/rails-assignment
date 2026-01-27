# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# NOTE: 全環境共通の seed。実運用では環境別に分ける想定。

# ===========================
#           User
# ===========================
# User テーブルにデフォルトのユーザを追加
users = [
  {
    email: "emptytest@example.com",
    password: "password",
    password_confirmation: "password"
  },
  {
    email: "user1@example.com",
    password: "password1",
    password_confirmation: "password1"
  },
  {
    email: "user2@example.com",
    password: "password2",
    password_confirmation: "password2"
  }
]

users.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.password = attrs[:password]
    user.password_confirmation = attrs[:password_confirmation]
  end
end

# ===========================
#           Photo
# ===========================
# seed用画像パス
seed_images_dir = Rails.root.join("db/seeds/images")

# Userを取得（normalize_emailがあるので小文字で）
user1 = User.find_by!(email: "user1@example.com")
user2 = User.find_by!(email: "user2@example.com")

# Photo は毎回作り直す（増殖防止）
user1.photos.destroy_all
user2.photos.destroy_all

photos = [
  {
    user: user1,
    title: "サンプル1",
    file: "sample1.jpg",
    content_type: "image/jpeg"
  },
  {
    user: user1,
    title: "サンプル2",
    file: "sample2.jpg",
    content_type: "image/jpeg"
  },
  {
    user: user2,
    title: "サンプル3",
    file: "sample3.jpg",
    content_type: "image/jpeg"
  }
]

photos.each do |p|
  begin
    photo = p[:user].photos.build(title: p[:title])

    path = seed_images_dir.join(p[:file])
    file = File.open(path)

    photo.image.attach(
      io: file,
      filename: p[:file],
      content_type: p[:content_type]
    )

    photo.save!
  ensure
    file&.close
  end
end
