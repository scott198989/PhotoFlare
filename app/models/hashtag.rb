class Hashtag < ApplicationRecord
  # Associations
  has_many :post_hashtags, dependent: :destroy
  has_many :posts, through: :post_hashtags

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :name, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" }

  # Callbacks
  before_save :normalize_name

  # Scopes
  scope :popular, -> { order(posts_count: :desc) }
  scope :trending, -> {
    joins(:post_hashtags)
      .where(post_hashtags: { created_at: 7.days.ago.. })
      .group(:id)
      .order('COUNT(post_hashtags.id) DESC')
  }

  # Find or create by name
  def self.find_or_create_by_name(name)
    normalized = name.to_s.downcase.strip.gsub(/^#/, '')
    find_or_create_by(name: normalized)
  end

  # Extract hashtags from text
  def self.extract_from_text(text)
    return [] if text.blank?
    text.scan(/#([a-zA-Z0-9_]+)/).flatten.map(&:downcase).uniq
  end

  private

  def normalize_name
    self.name = name.to_s.downcase.strip.gsub(/^#/, '')
  end
end
