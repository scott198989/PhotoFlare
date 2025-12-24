class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :body, presence: true

  # Callbacks
  after_create_commit :notify_post_owner

  private

  def notify_post_owner
    NotificationService.notify_comment(self)
  end
end
