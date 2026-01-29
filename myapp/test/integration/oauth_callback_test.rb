require "test_helper"

class OauthCallbackTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = User.create!(email: "test@example.com", password: "password", password_confirmation: "password")
    post session_path, params: { login_form: { email: @user.email, password: "password" } }

    @orig_env = ENV.to_h
    ENV["OAUTH_AUTHORIZE_URL"] = "http://example.com/oauth/authorize"
    ENV["OAUTH_TOKEN_URL"] = "http://example.com/oauth/token"
    ENV["OAUTH_CLIENT_ID"] = "client_id"
    ENV["OAUTH_CLIENT_SECRET"] = "client_secret"
    ENV["OAUTH_REDIRECT_URI"] = "http://localhost:3000/oauth/callback"
    ENV["OAUTH_SCOPE"] = "read"
    ENV["TWEET_CREATE_URL"] = "http://example.com/api/tweets"
  end

  teardown do
    # ENVを元に戻す（他テストへ影響させない）
    ENV.replace(@orig_env)
  end

  test "code が渡されたら token を取得して session に保存し一覧へ戻る" do
    received = []
    fake_client = Object.new
    fake_client.define_singleton_method(:exchange_code_for_token!) do |code:|
      received << code
      "token-123"
    end

    Oauth::TokenClient.stub(:new, fake_client) do
      get callback_oauth_path(code: "abc")
    end

    assert_redirected_to photos_path
    assert_equal "token-123", session[:oauth_access_token]
    assert_equal [ "abc" ], received
  end

  test "code が空なら token 取得せずエラーで一覧へ戻る" do
    Oauth::TokenClient.stub(:new, ->(*) { raise "should not be called" }) do
      get callback_oauth_path(code: "")
    end

    assert_redirected_to photos_path
    follow_redirect!
    assert_select ".flash-alert", /認可コードが取得できませんでした/
  end

  test "設定が未完了ならエラーで一覧へ戻る" do
    ENV.delete("OAUTH_TOKEN_URL")

    get callback_oauth_path(code: "abc")
    assert_redirected_to photos_path
    follow_redirect!
    assert_select ".flash-alert", /OAuth連携の設定が未完了です/
  end

  test "token 取得で例外が起きたらエラーで一覧へ戻る" do
    fake_client = Object.new
    fake_client.define_singleton_method(:exchange_code_for_token!) do |code:|
      raise "boom"
    end

    Oauth::TokenClient.stub(:new, fake_client) do
      get callback_oauth_path(code: "abc")
    end

    assert_redirected_to photos_path
    follow_redirect!
    assert_select ".flash-alert", /OAuth連携に失敗しました/
  end
end
