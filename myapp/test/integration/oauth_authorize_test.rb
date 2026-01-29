require "test_helper"

class OauthAuthorizeTest < ActionDispatch::IntegrationTest
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

  teardown { ENV.replace(@orig_env) }

  test "authorize を押すと外部の認可URLへリダイレクトされる" do
    get authorize_oauth_path

    assert_response :redirect
    loc = response.headers["Location"]
    assert loc.start_with?("http://example.com/oauth/authorize?")

    # クエリの存在チェック
    assert_includes loc, "response_type=code"
    assert_includes loc, "client_id=client_id"
    assert_includes loc, "redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Foauth%2Fcallback"
    assert_includes loc, "scope=read"
  end
end
