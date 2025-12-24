class PostHashtag < ApplicationRecord
  # Associations
  belongs_to :post
  belongs_to :hashtag, counter_cache: :posts_count

  # Validations
  validates :hashtag_id, uniqueness: { scope: :post_id }
end
