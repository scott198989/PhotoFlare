class NotificationService
  class << self
    # Create a like notification
    def notify_like(like)
      return if like.user == like.post.user

      create_notification(
        recipient: like.post.user,
        actor: like.user,
        notifiable: like,
        action: 'liked'
      )
    end

    # Create a comment notification
    def notify_comment(comment)
      return if comment.user == comment.post.user

      create_notification(
        recipient: comment.post.user,
        actor: comment.user,
        notifiable: comment,
        action: 'commented'
      )

      # Also notify mentioned users
      notify_mentions(comment)
    end

    # Create a follow notification
    def notify_follow(follow)
      action = follow.accepted? ? 'followed' : 'follow_requested'

      create_notification(
        recipient: follow.followed,
        actor: follow.follower,
        notifiable: follow,
        action: action
      )
    end

    # Create follow accepted notification
    def notify_follow_accepted(follow)
      create_notification(
        recipient: follow.follower,
        actor: follow.followed,
        notifiable: follow,
        action: 'follow_accepted'
      )
    end

    # Create mention notifications from a comment
    def notify_mentions(comment)
      mentioned_usernames = comment.body.to_s.scan(/@(\w+)/).flatten.uniq

      mentioned_usernames.each do |username|
        user = User.find_by(username: username)
        next if user.nil? || user == comment.user || user == comment.post.user

        create_notification(
          recipient: user,
          actor: comment.user,
          notifiable: comment,
          action: 'mentioned'
        )
      end
    end

    private

    def create_notification(recipient:, actor:, notifiable:, action:)
      Notification.create!(
        recipient: recipient,
        actor: actor,
        notifiable: notifiable,
        action: action
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create notification: #{e.message}"
      nil
    end
  end
end
