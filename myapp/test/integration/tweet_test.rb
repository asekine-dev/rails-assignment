require "test_helper"

class TweetTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )

    # ログイン（これで session[:user_id] が入る）
    post session_path, params: { login_form: { email: @user.email, password: "password" } }

    # OAuthの設定を満たす（callbackが弾かれないように）
    @orig_env = ENV.to_h
    ENV["OAUTH_AUTHORIZE_URL"] = "http://example.com/oauth/authorize"
    ENV["OAUTH_TOKEN_URL"]      = "http://example.com/oauth/token"
    ENV["OAUTH_CLIENT_ID"]      = "client_id"
    ENV["OAUTH_CLIENT_SECRET"]  = "client_secret"
    ENV["OAUTH_REDIRECT_URI"]   = "http://localhost:3000/oauth/callback"
    ENV["OAUTH_SCOPE"]          = "read"
    ENV["TWEET_CREATE_URL"]     = "http://example.com/api/tweets"
  end

  teardown do
    ENV.replace(@orig_env)
  end

  test "token があると tweet でき、一覧へ戻る" do
    photo = @user.photos.create!(title: "hello", image: uploaded_image)

    # token は callback 経由で入れる
    fake_token_client = Object.new
    fake_token_client.define_singleton_method(:exchange_code_for_token!) { |code:| "token-123" }

    Oauth::TokenClient.stub(:new, fake_token_client) do
      get callback_oauth_path(code: "abc")
    end
    assert_equal "token-123", session[:oauth_access_token]

    calls = []
    fake_tweet_client = Object.new
    fake_tweet_client.define_singleton_method(:create_tweet!) do |title:, url:|
      calls << { title: title, url: url }
      { "id" => 1 }
    end

    TweetClient.stub(:new, fake_tweet_client) do
      post tweet_photo_path(photo)
    end

    assert_redirected_to photos_path
    assert_equal 1, calls.size
    assert_equal "hello", calls[0][:title]
    assert_includes calls[0][:url], "/rails/active_storage" # URL形式のざっくり検証
  end

  test "token がないとエラーで一覧へ戻る" do
    photo = @user.photos.create!(title: "hello", image: uploaded_image)

    TweetClient.stub(:new, ->(*) { raise "should not be called" }) do
      post tweet_photo_path(photo)
    end

    assert_redirected_to photos_path
    follow_redirect!
    assert_select ".flash-alert", /OAuth連携が必要です/
  end

  # token を session に入れる
  def connect_oauth(token: "token-123")
    fake_token_client = Object.new
    fake_token_client.define_singleton_method(:exchange_code_for_token!) { |code:| token }

    Oauth::TokenClient.stub(:new, fake_token_client) do
      get callback_oauth_path(code: "abc")
    end
    assert_equal token, session[:oauth_access_token]
  end

  test "画像がないとエラーで一覧へ戻る" do
    # 画像なしPhotoを作る（バリデーション回避）
    photo = @user.photos.new(title: "hello")
    photo.save!(validate: false)

    connect_oauth(token: "token-123")

    post tweet_photo_path(photo)

    assert_redirected_to photos_path
    follow_redirect!
    assert_select ".flash-alert", /画像がありません/
  end
end
