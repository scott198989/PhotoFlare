class ExploreController < ApplicationController
  before_action :authenticate_user!

  # GET /explore
  def index
    @trending_hashtags = Hashtag.trending.limit(10)
    @popular_posts = Post.popular
                          .includes(user: { profile_pic_attachment: :blob }, images_attachments: :blob)
                          .limit(24)
  end

  # GET /explore/search
  def search
    @query = params[:q].to_s.strip

    if @query.present?
      if @query.start_with?('#')
        # Hashtag search
        @hashtags = Hashtag.where('name ILIKE ?', "%#{@query.gsub('#', '')}%").limit(10)
        @posts = Post.with_hashtag(@query.gsub('#', ''))
                      .includes(user: { profile_pic_attachment: :blob }, images_attachments: :blob)
                      .limit(24)
        @users = []
      elsif @query.start_with?('@')
        # User search
        username = @query.gsub('@', '')
        @users = User.where('username ILIKE ?', "%#{username}%")
                      .includes(profile_pic_attachment: :blob)
                      .limit(20)
        @hashtags = []
        @posts = []
      else
        # General search
        @users = User.where('username ILIKE ? OR full_name ILIKE ?', "%#{@query}%", "%#{@query}%")
                      .includes(profile_pic_attachment: :blob)
                      .limit(10)
        @hashtags = Hashtag.where('name ILIKE ?', "%#{@query}%").limit(5)
        @posts = Post.search(@query)
                      .includes(user: { profile_pic_attachment: :blob }, images_attachments: :blob)
                      .limit(24)
      end
    else
      @users = []
      @hashtags = []
      @posts = []
    end

    respond_to do |format|
      format.html
      format.turbo_stream
      format.json do
        render json: {
          users: @users.map { |u| user_json(u) },
          hashtags: @hashtags.map { |h| hashtag_json(h) },
          posts_count: @posts.count
        }
      end
    end
  end

  # GET /explore/hashtag/:tag
  def hashtag
    @hashtag = Hashtag.find_by!(name: params[:tag].to_s.downcase)
    @posts = @hashtag.posts
                      .includes(user: { profile_pic_attachment: :blob }, images_attachments: :blob)
                      .recent
                      .limit(48)
  rescue ActiveRecord::RecordNotFound
    redirect_to explore_path, alert: "Hashtag ##{params[:tag]} not found"
  end

  private

  def user_json(user)
    {
      id: user.id,
      username: user.username,
      full_name: user.full_name,
      profile_pic: user.profile_pic.attached? ? url_for(user.profile_pic) : nil,
      is_following: current_user.followings.include?(user)
    }
  end

  def hashtag_json(hashtag)
    {
      id: hashtag.id,
      name: hashtag.name,
      posts_count: hashtag.posts_count
    }
  end
end
