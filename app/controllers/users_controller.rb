class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    if params[:search_query].present?
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(params[:search_query])
      @users = User.where("username LIKE ?", "%#{sanitized_query}%")
                   .includes(profile_pic_attachment: :blob)
                   .limit(20)
    else
      @users = []
    end

    if turbo_frame_request?
      render partial: "layouts/search_results", locals: { users: @users }
    end
  end

  def show
    authorize @user
    @posts = @user.posts
                  .includes(:likes, :comments, images_attachments: :blob)
                  .order(created_at: :desc)
  end

  private

  def set_user
    @user = User.includes(
      profile_pic_attachment: :blob,
      posts: { images_attachments: :blob }
    ).find(params[:id])
  end
end