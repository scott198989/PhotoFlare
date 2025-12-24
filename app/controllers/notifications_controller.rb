class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # GET /notifications
  def index
    @notifications = current_user.notifications
                                  .includes(actor: { profile_pic_attachment: :blob }, notifiable: [:post])
                                  .recent
                                  .limit(50)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          notifications: @notifications.map { |n| notification_json(n) },
          unread_count: current_user.notifications.unread.count
        }
      end
    end
  end

  # POST /notifications/:id/mark_as_read
  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { success: true } }
    end
  end

  # POST /notifications/mark_all_as_read
  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { success: true } }
    end
  end

  private

  def notification_json(notification)
    {
      id: notification.id,
      action: notification.action,
      message: notification.message,
      actor: {
        id: notification.actor.id,
        username: notification.actor.username,
        profile_pic: notification.actor.profile_pic.attached? ? url_for(notification.actor.profile_pic) : nil
      },
      created_at: notification.created_at.iso8601,
      read: notification.read?,
      notifiable_type: notification.notifiable_type,
      notifiable_id: notification.notifiable_id
    }
  end
end
