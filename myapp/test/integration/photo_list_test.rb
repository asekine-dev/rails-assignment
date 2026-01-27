require "test_helper"

class PhotoListTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user1 = User.create!(email: "user1@example.com", password: "password", password_confirmation: "password")
    @user2 = User.create!(email: "user2@example.com", password: "password", password_confirmation: "password")
  end

  def login_as(user, password: "password")
    post session_path, params: { login_form: { email: user.email, password: password } }
    follow_redirect!
  end

  test "ログイン済みなら写真一覧が表示される（0件でもOK）" do
    login_as(@user1)

    assert_response :success
    assert_select ".photo-grid"
    assert_select ".photo-card", count: 0
  end

  test "ログインユーザの写真だけが表示される" do
    # user1の写真
    @user1.photos.create!(title: "user1-photo1")
    @user1.photos.create!(title: "user1-photo2")

    # user2の写真（表示されないはず）
    @user2.photos.create!(title: "user2-photo1")

    login_as(@user1)

    assert_select ".photo-title", text: "user1-photo1"
    assert_select ".photo-title", text: "user1-photo2"
    assert_select ".photo-title", text: "user2-photo1", count: 0
  end

  test "写真は最後にアップロードした順で表示される" do
    older = @user1.photos.create!(title: "older", created_at: 2.days.ago, updated_at: 2.days.ago)
    newer = @user1.photos.create!(title: "newer", created_at: 1.hour.ago, updated_at: 1.hour.ago)

    login_as(@user1)

    body = @response.body
    assert body.index("newer") < body.index("older"), "newer が older より先に表示されるべき"
  end
end
