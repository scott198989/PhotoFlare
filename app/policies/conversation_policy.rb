class ConversationPolicy < ApplicationPolicy
  def show?
    participant?
  end

  def create?
    user.present?
  end

  def send_message?
    participant?
  end

  private

  def participant?
    record.participants.include?(user)
  end

  class Scope < Scope
    def resolve
      scope.joins(:participants).where(conversation_participants: { user_id: user.id })
    end
  end
end
