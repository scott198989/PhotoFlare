class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def follow?
    user != record && !already_following?
  end

  def unfollow?
    user != record && already_following?
  end

  def view_posts?
    return true unless record.private?
    return true if user == record
    return true if user.followings.include?(record)
    false
  end

  def view_followers?
    view_posts?
  end

  def view_following?
    view_posts?
  end

  private

  def already_following?
    user.followings.include?(record) || user.waiting_followings.include?(record)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
