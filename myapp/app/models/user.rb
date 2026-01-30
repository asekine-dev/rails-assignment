class User < ApplicationRecord
  has_many :photos, dependent: :destroy

  has_secure_password
  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  # パスワードは新規ユーザ作成時のみ必須バリデーション
  validates :password, presence: true, on: :create

  # 以下、プライベートメソッド
  private

  def normalize_email
    # emailの入力があるとき、大文字が含まれていても小文字へ変換する
    self.email = email.to_s.strip.downcase
  end
end
