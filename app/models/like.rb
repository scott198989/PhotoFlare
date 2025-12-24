class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }

  # Callbacks
  after_create_commit :notify_post_owner

  private

  def notify_post_owner
    NotificationService.notify_like(self)
  end
end
