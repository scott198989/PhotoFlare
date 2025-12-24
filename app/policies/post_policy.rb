class PostPolicy < ApplicationPolicy
  def show?
    return true unless record.user.private?
    return true if user == record.user
    return true if user.followings.include?(record.user)
    false
  end

  def create?
    user.present?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def like?
    show?
  end

  def comment?
    show?
  end

  class Scope < Scope
    def resolve
      # Show posts from followed users and public accounts
      public_users = User.where(private: false).pluck(:id)
      followed_users = user.followings.pluck(:id)
      allowed_users = (public_users + followed_users + [user.id]).uniq

      scope.where(user_id: allowed_users)
    end
  end
end
