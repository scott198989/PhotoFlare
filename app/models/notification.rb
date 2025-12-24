class Notification < ApplicationRecord
  # Constants
  ACTIONS = %w[liked commented followed mentioned follow_requested follow_accepted].freeze

  # Associations
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  # Validations
  validates :action, presence: true, inclusion: { in: ACTIONS }

  # Callbacks
  after_create_commit :broadcast_notification

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Check if notification is read
  def read?
    read_at.present?
  end

  # Mark as read
  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  # Get message for notification
  def message
    case action
    when 'liked'
      "liked your post"
    when 'commented'
      "commented on your post"
    when 'followed'
      "started following you"
    when 'mentioned'
      "mentioned you in a comment"
    when 'follow_requested'
      "requested to follow you"
    when 'follow_accepted'
      "accepted your follow request"
    else
      "interacted with you"
    end
  end

  private

  def broadcast_notification
    NotificationsChannel.broadcast_to(
      recipient,
      {
        type: 'new_notification',
        notification: {
          id: id,
          action: action,
          message: message,
          actor: {
            id: actor.id,
            username: actor.username,
            profile_pic: actor.profile_pic.attached? ? Rails.application.routes.url_helpers.url_for(actor.profile_pic) : nil
          },
          created_at: created_at.iso8601,
          read: read?,
          notifiable_type: notifiable_type,
          notifiable_id: notifiable_id
        }
      }
    )
  end
end
