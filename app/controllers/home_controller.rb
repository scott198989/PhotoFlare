class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stories
  before_action :set_suggestions
  before_action :set_feeds

  def index
  end

  private

  # Load active stories from followed users
  # Gracefully handles missing stories table (before migrations)
  def set_stories
    return @stories_by_user = {} unless table_exists?(:stories)

    followed_ids = current_user.followings.pluck(:id) + [current_user.id]
    @stories_by_user = Story.where(user_id: followed_ids)
                            .active
                            .includes(user: { profile_pic_attachment: :blob }, media_attachment: :blob)
                            .group_by(&:user)
  rescue ActiveRecord::StatementInvalid
    @stories_by_user = {}
  end

  # Fixed N+1 queries with includes
  def set_feeds
    @feeds = Post.where(user: [current_user] + current_user.followings)
                 .includes(
                   :likes,
                   comments: { user: { profile_pic_attachment: :blob } },
                   user: { profile_pic_attachment: :blob },
                   images_attachments: :blob
                 )
                 .order(created_at: :desc)
                 .limit(20)
  end

  def set_suggestions
    # Get followers of followers and followings as suggestions
    excluded_ids = [current_user.id] + current_user.followings.pluck(:id)

    # Get users followed by people you follow
    mutual_suggestions = User.joins(:followers)
                              .where(followers: { id: current_user.followings.pluck(:id) })
                              .where.not(id: excluded_ids)
                              .distinct
                              .limit(10)

    # Fill remaining with random users
    remaining_count = 5 - mutual_suggestions.count
    if remaining_count > 0
      random_users = User.where.not(id: excluded_ids + mutual_suggestions.pluck(:id))
                         .order('RANDOM()')
                         .limit(remaining_count)
      @suggestions = (mutual_suggestions + random_users).sample(5)
    else
      @suggestions = mutual_suggestions.sample(5)
    end

    # Eager load profile pics
    @suggestions = User.where(id: @suggestions.map(&:id))
                       .includes(profile_pic_attachment: :blob)
  end

  # Helper to check if table exists (for graceful degradation before migrations)
  def table_exists?(table_name)
    ActiveRecord::Base.connection.table_exists?(table_name)
  rescue ActiveRecord::NoDatabaseError
    false
  end
end
