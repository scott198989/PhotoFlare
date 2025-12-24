class Message < ApplicationRecord
  # Constants
  MESSAGE_TYPES = %w[text image post_share].freeze

  # Associations
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'
  belongs_to :shared_post, class_name: 'Post', optional: true
  has_one_attached :image

  # Validations
  validates :body, presence: true, if: -> { message_type == 'text' }
  validates :message_type, inclusion: { in: MESSAGE_TYPES }
  validates :shared_post, presence: true, if: -> { message_type == 'post_share' }

  # Callbacks
  after_create_commit :update_conversation_timestamp
  after_create_commit :broadcast_message

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }

  # Check if message is from a specific user
  def from?(user)
    sender_id == user.id
  end

  # Get recipient (for 1-on-1 conversations)
  def recipient
    conversation.participants.where.not(id: sender_id).first
  end

  private

  def update_conversation_timestamp
    conversation.touch_last_message!
  end

  def broadcast_message
    # Broadcast to all participants in the conversation
    conversation.participants.each do |participant|
      next if participant == sender

      ConversationChannel.broadcast_to(
        participant,
        {
          type: 'new_message',
          conversation_id: conversation_id,
          message: {
            id: id,
            body: body,
            message_type: message_type,
            sender: {
              id: sender.id,
              username: sender.username,
              profile_pic: sender.profile_pic.attached? ? Rails.application.routes.url_helpers.url_for(sender.profile_pic) : nil
            },
            created_at: created_at.iso8601,
            shared_post_id: shared_post_id
          }
        }
      )
    end
  end
end
