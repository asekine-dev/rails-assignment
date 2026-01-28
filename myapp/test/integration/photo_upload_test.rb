require "test_helper"

class PhotoUploadTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = User.create!(email: "test@example.com", password: "password", password_confirmation: "password")
    post session_path, params: { login_form: { email: "test@example.com", password: "password" } }
  end

  test "写真をアップロードすると一覧へリダイレクトし、先頭に表示される" do
    post photos_path, params: {
      photo: {
        title: "my photo",
        image: uploaded_image
      }
    }

    assert_redirected_to photos_path
    follow_redirect!
    assert_response :success
    assert_select ".photo-title", text: "my photo"
  end

  test "title 未入力だと 422 で new を再表示" do
    post photos_path, params: {
      photo: { title: "", image: uploaded_image }
    }

    assert_response :unprocessable_entity
    assert_select "h1", /アップロード|新規/  # 見出しに合わせて調整
    assert_select "li", /タイトルを入力してください/
  end

  test "image 未入力だと 422 で new を再表示" do
    post photos_path, params: {
      photo: { title: "my photo", image: nil }
    }

    assert_response :unprocessable_entity
    assert_select "li", /画像ファイルを入力してください|画像を入力してください/
  end

  test "title が31文字だとエラー" do
    post photos_path, params: {
      photo: { title: "a" * 31, image: uploaded_image }
    }

    assert_response :unprocessable_entity
    assert_select "li", /タイトルは30文字以内で入力してください/
  end
end
