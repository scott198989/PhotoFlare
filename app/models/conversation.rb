class Conversation < ApplicationRecord
  # Associations
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :messages, dependent: :destroy

  # Validations
  validates :conversation_participants, length: { minimum: 2, message: "must have at least 2 participants" }

  # Scopes
  scope :ordered, -> { order(last_message_at: :desc) }
  scope :for_user, ->(user) { joins(:conversation_participants).where(conversation_participants: { user_id: user.id }) }

  # Find or create a conversation between two users
  def self.between(user1, user2)
    # Find existing conversation
    conversation = joins(:conversation_participants)
                    .where(conversation_participants: { user_id: [user1.id, user2.id] })
                    .group(:id)
                    .having('COUNT(DISTINCT conversation_participants.user_id) = 2')
                    .first

    return conversation if conversation

    # Create new conversation
    transaction do
      conversation = create!(last_message_at: Time.current)
      conversation.conversation_participants.create!(user: user1)
      conversation.conversation_participants.create!(user: user2)
    end

    conversation
  end

  # Get the other participant in a 1-on-1 conversation
  def other_participant(user)
    participants.where.not(id: user.id).first
  end

  # Get unread count for a user
  def unread_count_for(user)
    participant = conversation_participants.find_by(user: user)
    return 0 unless participant

    messages.where.not(sender: user)
            .where('created_at > ?', participant.last_read_at || Time.at(0))
            .count
  end

  # Mark as read for a user
  def mark_as_read!(user)
    participant = conversation_participants.find_by(user: user)
    participant&.update!(last_read_at: Time.current)
  end

  # Get last message
  def last_message
    messages.order(created_at: :desc).first
  end

  # Update last_message_at
  def touch_last_message!
    update!(last_message_at: Time.current)
  end
end
