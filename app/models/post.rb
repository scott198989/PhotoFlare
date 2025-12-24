class Post < ApplicationRecord
  # Associations
  belongs_to :user
  has_many_attached :images
  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user
  has_many :comments, dependent: :destroy
  has_many :post_hashtags, dependent: :destroy
  has_many :hashtags, through: :post_hashtags
  has_many :shared_messages, class_name: 'Message', foreign_key: 'shared_post_id', dependent: :nullify

  # Validations
  validates :images, presence: true, blob: { content_type: :image }

  # Callbacks
  after_save :extract_hashtags

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { left_joins(:likes).group(:id).order('COUNT(likes.id) DESC') }
  scope :with_hashtag, ->(tag_name) {
    joins(:hashtags).where(hashtags: { name: tag_name.to_s.downcase.gsub(/^#/, '') })
  }

  # Search posts by caption
  scope :search, ->(query) {
    where('caption ILIKE ?', "%#{query}%") if query.present?
  }

  private

  def extract_hashtags
    return unless saved_change_to_caption?

    # Clear existing hashtags
    post_hashtags.destroy_all

    # Extract new hashtags
    tag_names = Hashtag.extract_from_text(caption)

    tag_names.each do |name|
      hashtag = Hashtag.find_or_create_by_name(name)
      post_hashtags.create(hashtag: hashtag) unless hashtags.include?(hashtag)
    end
  end
end
