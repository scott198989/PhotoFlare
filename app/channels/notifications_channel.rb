class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # Mark notification as read
  def mark_read(data)
    notification = current_user.notifications.find_by(id: data['notification_id'])
    notification&.mark_as_read!
  end

  # Mark all notifications as read
  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    NotificationsChannel.broadcast_to(
      current_user,
      { type: 'all_read' }
    )
  end
end
