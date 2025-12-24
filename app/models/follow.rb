class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User", foreign_key: "follower_id"
  belongs_to :followed, class_name: "User", foreign_key: "followed_id"

  # Callbacks
  before_create :check_privacy
  after_create_commit :notify_followed_user
  after_update_commit :notify_follow_accepted, if: :saved_change_to_accepted?

  def accept
    self.update(accepted: true)
  end

  def accepted?
    accepted == true
  end

  private

  def check_privacy
    self.accepted = true unless self.followed.private
  end

  def notify_followed_user
    NotificationService.notify_follow(self)
  end

  def notify_follow_accepted
    return unless accepted?
    NotificationService.notify_follow_accepted(self)
  end
end
