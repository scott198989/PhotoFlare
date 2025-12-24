class ConversationParticipant < ApplicationRecord
  # Associations
  belongs_to :conversation
  belongs_to :user

  # Validations
  validates :user_id, uniqueness: { scope: :conversation_id, message: "is already a participant" }

  # Scopes
  scope :unread, -> { where('last_read_at IS NULL OR last_read_at < conversations.last_message_at') }

  # Toggle mute
  def toggle_mute!
    update!(muted: !muted)
  end
end
