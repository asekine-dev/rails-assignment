require "test_helper"

class AuthGuardTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "未ログインで写真一覧へアクセスするとログイン画面へリダイレクトされる" do
    get photos_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_select 'form[action=?]', session_path
    assert_select 'input[name=?]', 'login_form[email]'
  end
end
