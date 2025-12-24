class Story < ApplicationRecord
  # Constants
  EXPIRATION_TIME = 24.hours

  # Associations
  belongs_to :user
  has_one_attached :media
  has_many :story_views, dependent: :destroy
  has_many :viewers, through: :story_views, source: :user

  # Validations
  validates :expires_at, presence: true
  validates :media, presence: true

  # Callbacks
  before_validation :set_expiration, on: :create

  # Scopes
  scope :active, -> { where(active: true).where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :recent, -> { order(created_at: :desc) }

  # Get stories from user and their followings for feed
  scope :for_user_feed, ->(user) {
    active
      .where(user: [user] + user.followings)
      .recent
  }

  # Get all active stories grouped by user for feed display
  def self.feed_for(user)
    for_user_feed(user)
      .includes(user: { profile_pic_attachment: :blob }, media_attachment: :blob)
      .group_by(&:user)
  end

  # Check if story is expired
  def expired?
    expires_at <= Time.current
  end

  # Check if story has been viewed by a user
  def viewed_by?(user)
    story_views.exists?(user: user)
  end

  # Mark story as viewed by user
  def mark_viewed_by!(user)
    return if user == self.user # Don't track own views

    story_views.find_or_create_by(user: user) do |view|
      view.viewed_at = Time.current
    end
  end

  # Get view count
  def view_count
    story_views.count
  end

  # Deactivate expired stories (called by background job)
  def self.deactivate_expired!
    expired.update_all(active: false)
  end

  private

  def set_expiration
    self.expires_at ||= EXPIRATION_TIME.from_now
  end
end
