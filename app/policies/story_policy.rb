class StoryPolicy < ApplicationPolicy
  def show?
    return true if user == record.user
    return true unless record.user.private?
    return true if user.followings.include?(record.user)
    false
  end

  def create?
    user.present?
  end

  def destroy?
    owner?
  end

  class Scope < Scope
    def resolve
      # Show stories from followed users and self (for active stories)
      followed_users = user.followings.pluck(:id)
      allowed_users = (followed_users + [user.id]).uniq

      scope.where(user_id: allowed_users).active
    end
  end
end
