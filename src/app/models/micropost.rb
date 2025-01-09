class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) }

  validates :user_id, presence: true
  validates :content,
              length: { maximum: 140 },
              presence: true
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "有効な画像をアップロードしてください" },
                      size:         { less_than: 5.megabytes,
                                      message:   "5MB以下の画像をアップロードしてください" }
end
