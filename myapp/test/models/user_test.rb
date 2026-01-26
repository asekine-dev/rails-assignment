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
end
