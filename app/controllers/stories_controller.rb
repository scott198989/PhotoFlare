class StoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story, only: [:show, :destroy]

  # GET /stories
  def index
    @stories_by_user = policy_scope(Story).feed_for(current_user)
    respond_to do |format|
      format.html
      format.json { render json: @stories_by_user }
    end
  end

  # GET /stories/:id
  def show
    authorize @story
    @story.mark_viewed_by!(current_user)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          id: @story.id,
          user: {
            id: @story.user.id,
            username: @story.user.username,
            profile_pic: @story.user.profile_pic.attached? ? url_for(@story.user.profile_pic) : nil
          },
          media_url: url_for(@story.media),
          created_at: @story.created_at,
          expires_at: @story.expires_at,
          view_count: @story.view_count,
          viewed: @story.viewed_by?(current_user)
        }
      end
    end
  end

  # POST /stories
  def create
    @story = current_user.stories.build(story_params)
    authorize @story

    respond_to do |format|
      if @story.save
        format.html { redirect_to root_path, notice: 'Story was successfully created.' }
        format.json { render json: { id: @story.id, success: true } }
      else
        format.html { redirect_to root_path, alert: @story.errors.full_messages.join(', ') }
        format.json { render json: { errors: @story.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/:id
  def destroy
    authorize @story

    @story.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Story was successfully deleted.' }
      format.json { render json: { success: true } }
    end
  end

  # GET /stories/user/:user_id
  def user_stories
    @user = User.find(params[:user_id])
    @stories = @user.active_stories.includes(media_attachment: :blob)

    respond_to do |format|
      format.html
      format.json do
        render json: @stories.map { |story|
          {
            id: story.id,
            media_url: url_for(story.media),
            created_at: story.created_at,
            expires_at: story.expires_at,
            viewed: story.viewed_by?(current_user)
          }
        }
      end
    end
  end

  # POST /stories/:id/view
  def mark_viewed
    @story = Story.find(params[:id])
    @story.mark_viewed_by!(current_user)

    render json: { success: true }
  end

  private

  def set_story
    @story = Story.find(params[:id])
  end

  def story_params
    params.require(:story).permit(:media)
  end
end
