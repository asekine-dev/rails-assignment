# ログイン画面の入力値保持とバリデーションを担うフォームオブジェクト
class LoginForm
  include ActiveModel::Model

  EMAIL_MAX_LENGTH = 255
  PASSWORD_MAX_LENGTH = 72

  attr_accessor :email, :password

  validates :email, presence: true, length: { maximum: EMAIL_MAX_LENGTH }
  validates :password, presence: true, length: { maximum: PASSWORD_MAX_LENGTH }

  def normalized_email
    email.to_s.strip.downcase
  end
end