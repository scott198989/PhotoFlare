class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  # POST /conversations/:conversation_id/messages
  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user

    respond_to do |format|
      if @message.save
        format.html { redirect_to conversation_path(@conversation) }
        format.json { render json: { id: @message.id, success: true } }
        format.turbo_stream
      else
        format.html { redirect_to conversation_path(@conversation), alert: 'Failed to send message' }
        format.json { render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body, :message_type, :shared_post_id, :image)
  end
end
