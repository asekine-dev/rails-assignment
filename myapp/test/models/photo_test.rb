require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = User.create!(email: "test@example.com", password: "password", password_confirmation: "password")
  end

  test "title と image があれば有効" do
    photo = @user.photos.new(title: "hello")
    photo.image.attach(uploaded_image)

    assert photo.valid?
  end

  test "title が未入力だと無効" do
    photo = @user.photos.new(title: "")
    photo.image.attach(uploaded_image)

    assert_not photo.valid?
    assert_includes photo.errors[:title], "を入力してください"
  end

  test "title は30文字まで" do
    photo = @user.photos.new(title: "a" * 31)
    photo.image.attach(uploaded_image)

    assert_not photo.valid?
    assert_includes photo.errors[:title], "は30文字以内で入力してください"
  end

  test "image が未入力だと無効" do
    photo = @user.photos.new(title: "hello")

    assert_not photo.valid?
    assert_includes photo.errors[:image], "を入力してください"
  end

  test "image は jpg/jpeg/png/gif のみ許可" do
    photo = @user.photos.new(title: "hello")
    # テキストをjpg偽装ではなく、content_typeで落とす想定
    photo.image.attach(
      uploaded_image(filename: "not_image.txt", content_type: "text/plain")
    )

    assert_not photo.valid?
    assert_includes photo.errors[:image], "は jpg, jpeg, png, gif のみアップロード可能です"
  end
end
