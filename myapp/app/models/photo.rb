class Photo < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 30 }
  validates :image, presence: true
  validate :image_content_type

  private

  def image_content_type
    return unless image.attached?

    allowed = %w[image/jpeg image/png image/gif]
    unless allowed.include?(image.content_type)
      errors.add(:image, "は jpg, jpeg, png, gif のみアップロード可能です")
    end
  end
end
