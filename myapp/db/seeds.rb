# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# User テーブルにデフォルトのユーザを追加
# NOTE: 全環境共通の seed。実運用では環境別に分ける想定。
users = [
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