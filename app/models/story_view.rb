class StoryView < ApplicationRecord
  # Associations
  belongs_to :story
  belongs_to :user

  # Validations
  validates :viewed_at, presence: true
  validates :user_id, uniqueness: { scope: :story_id, message: "has already viewed this story" }

  # Callbacks
  before_validation :set_viewed_at, on: :create

  # Scopes
  scope :recent, -> { order(viewed_at: :desc) }

  private

  def set_viewed_at
    self.viewed_at ||= Time.current
  end
end
