class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]

  # GET /conversations
  def index
    @conversations = policy_scope(Conversation)
                      .includes(
                        participants: { profile_pic_attachment: :blob },
                        messages: :sender
                      )
                      .ordered
  end

  # GET /conversations/:id
  def show
    authorize @conversation
    @conversation.mark_as_read!(current_user)
    @messages = @conversation.messages
                              .includes(sender: { profile_pic_attachment: :blob })
                              .chronological
    @other_user = @conversation.other_participant(current_user)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          conversation: {
            id: @conversation.id,
            other_user: {
              id: @other_user.id,
              username: @other_user.username,
              profile_pic: @other_user.profile_pic.attached? ? url_for(@other_user.profile_pic) : nil
            }
          },
          messages: @messages.map { |m| message_json(m) }
        }
      end
    end
  end

  # POST /conversations
  def create
    @other_user = User.find(params[:user_id])
    @conversation = Conversation.between(current_user, @other_user)

    respond_to do |format|
      format.html { redirect_to conversation_path(@conversation) }
      format.json { render json: { id: @conversation.id } }
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def message_json(message)
    {
      id: message.id,
      body: message.body,
      message_type: message.message_type,
      sender: {
        id: message.sender.id,
        username: message.sender.username,
        profile_pic: message.sender.profile_pic.attached? ? url_for(message.sender.profile_pic) : nil
      },
      created_at: message.created_at.iso8601,
      is_own: message.sender == current_user
    }
  end
end
