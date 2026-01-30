require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "emailは保存前にstrip/downcaseで正規化される" do
    user = User.new(
      email: "  TEST@EXAMPLE.COM  ",
      password: "password",
      password_confirmation: "password"
    )

    user.valid? # before_validationが走る
    assert_equal "test@example.com", user.email
  end

  test "passwordは新規作成時のみ必須" do
    user = User.create!(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )

    # 更新時にpasswordを入れなくてもvalidであること
    user.email = "updated@example.com"
    assert user.valid?
  end

  test "emailは重複できない" do
    User.create!(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )

    user2 = User.new(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )

    assert_not user2.valid?
    assert_includes user2.errors[:email], "はすでに存在します"
  end

  test "emailは大小違いでも重複できない（正規化される）" do
    User.create!(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )

    user2 = User.new(
      email: "TEST@EXAMPLE.COM",
      password: "password",
      password_confirmation: "password"
    )

    assert_not user2.valid?
    assert_includes user2.errors[:email], "はすでに存在します"
  end

  test "emailの重複はDBのunique制約でも防がれる" do
    User.insert_all!([
      { email: "test@example.com", password_digest: BCrypt::Password.create("password"), created_at: Time.current, updated_at: Time.current }
    ])

    assert_raises(ActiveRecord::RecordNotUnique) do
      User.insert_all!([
        { email: "test@example.com", password_digest: BCrypt::Password.create("password"), created_at: Time.current, updated_at: Time.current }
      ])
    end
  end
end
