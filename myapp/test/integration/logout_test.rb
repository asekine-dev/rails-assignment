require "test_helper"

class LogoutTest < ActionDispatch::IntegrationTest
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

  test "ログアウトするとsessionがクリアされ、ログイン画面へ遷移する" do
    post session_path, params: { login_form: { email: "test@example.com", password: "password" } }
    assert_equal @user.id, session[:user_id]

    delete session_path

    assert_redirected_to new_session_path
    assert_nil session[:user_id]
    follow_redirect!
    assert_select "form[action=?]", session_path
    assert_select "input[name=?]", "login_form[email]"
  end
end
