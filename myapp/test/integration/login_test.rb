require "test_helper"

class LoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  test "email未入力ならエラーになり、ログイン画面が再表示される" do
    post session_path, params: { login_form: { email: "", password: "password" } }

    assert_response :unprocessable_entity
    assert_select "h1", "ログイン"
    assert_select "li", /メールアドレスを入力してください/
  end

  test "password未入力ならエラーになり、emailは保持される" do
    post session_path, params: { login_form: { email: "TEST@EXAMPLE.COM", password: "" } }

    assert_response :unprocessable_entity
    assert_select "li", /パスワードを入力してください/

    # emailが再表示で残っていること（value属性を見る）
    assert_select 'input[type="email"][value="TEST@EXAMPLE.COM"]'
  end

  test "認証情報が違う場合はエラー表示され、emailは保持される" do
    post session_path, params: { login_form: { email: "test@example.com", password: "wrong" } }

    assert_response :unprocessable_entity
    assert_select "li", /メールアドレスまたはパスワードが違います/

    # emailが再表示で残っていること（value属性を見る）
    assert_select 'input[type="email"][value="test@example.com"]'
  end

  test "メールアドレスは大小文字無視でログインできる" do
    post session_path, params: { login_form: { email: "TEST@EXAMPLE.COM", password: "password" } }

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "emailが長すぎるとエラーになる" do
    long_email = "a" * (LoginForm::EMAIL_MAX_LENGTH + 1) + "@example.com"
    post session_path, params: { login_form: { email: long_email, password: "password" } }

    assert_response :unprocessable_entity
    assert_select "li", /メールアドレスは.*文字以内で入力してください/
  end

  test "passwordが長すぎるとエラーになる" do
    long_password = "a" * (LoginForm::PASSWORD_MAX_LENGTH + 1)
    post session_path, params: { login_form: { email: "test@example.com", password: long_password } }

    assert_response :unprocessable_entity
    assert_select "li", /パスワードは.*文字以内で入力してください/
  end
  
  test "ログイン成功するとsessionにuser_idが入る" do
    post session_path, params: { login_form: { email: "test@example.com", password: "password" } }
    assert_equal @user.id, session[:user_id]
  end

  test "メールアドレスの前後空白があってもログインできる" do
    post session_path, params: { login_form: { email: "  test@example.com  ", password: "password" } }
    assert_redirected_to root_path
  end
end
