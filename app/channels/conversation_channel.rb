class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # Mark conversation as read
  def mark_read(data)
    conversation = current_user.conversations.find_by(id: data['conversation_id'])
    conversation&.mark_as_read!(current_user)
  end

  # Send typing indicator
  def typing(data)
    conversation = current_user.conversations.find_by(id: data['conversation_id'])
    return unless conversation

    conversation.participants.each do |participant|
      next if participant == current_user

      ConversationChannel.broadcast_to(
        participant,
        {
          type: 'typing',
          conversation_id: conversation.id,
          user: {
            id: current_user.id,
            username: current_user.username
          }
        }
      )
    end
  end

  # Stop typing indicator
  def stop_typing(data)
    conversation = current_user.conversations.find_by(id: data['conversation_id'])
    return unless conversation

    conversation.participants.each do |participant|
      next if participant == current_user

      ConversationChannel.broadcast_to(
        participant,
        {
          type: 'stop_typing',
          conversation_id: conversation.id,
          user_id: current_user.id
        }
      )
    end
  end
end
