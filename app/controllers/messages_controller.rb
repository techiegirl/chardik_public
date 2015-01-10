class MessagesController < ApplicationController
  #before_filter :authenticate_user!
  layout false, :only => [:get_user_message, :get_inbox, :get_outbox]
  def index
    @body_class = "messages_container"
    params[:recipient] ? @recipient = User.find(params[:recipient]).username : @recipient = ""
    @user_messages = current_user.received_messages
    @message = Message.new
    @user = current_user
  end
  
  def show
    @message = Message.read_message(params[:id], current_user)
  end
  
  def new
    @message = Message.new
  end
  
  def create
      recipient = User.find_by_username(params[:message][:recipient])
      @message = Message.new
      @message.body = params[:message][:body]
      @message.subject = params[:message][:subject]
      @message.sender_id = current_user.id
      @message.recipient_id = recipient.id
      @message.parent_id = params[:message][:parent_id]
    if @message.save
      redirect_to '/messages'
    else
      render 'new'
    end
  end
  
  def delete_selected
  end
  
  def message_read
    message_id = params[:user_id]
    message = Message.find(message_id)
    if message.message_read? == false
      @message = Message.read_message(message_id,current_user)
      respond_to do |format|
        format.js { render "message_read" }
      end
    end
  end
  
  def get_inbox
    @user_messages = current_user.received_messages
  end
  
  def get_outbox
    @user_messages = current_user.sent_messages
  end
  
  def get_user_message
    # @users = User.where("username like ?", "%#{params[:query]}%")
    #     respond_to do |format|
    #       format.html
    #       format.json { render :json => @users }
    #     end
    @users = User.order(:username).where(["username like ?","%#{params[:term]}%"])
    render json: @users.map{|user| user != current_user ? user.username : false }
  end
  
  def destroy
    @message = Message.find(:first, :conditions => ["messages.id = ? AND (sender_id = ? OR recipient_id = ?)", params[:id], current_user, current_user])
    if @message.mark_deleted(current_user)
      redirect_to '/messages'
    else
      redirect_to :back
    end
    
    # @message = Message.find(params[:id])
    #     if @message.destroy
    #       redirect_to user_messages_path(current_user)
    #     else
    #       redirect_to user_messages_path(current_user)
    #     end
  end
  private
    def set_user
      @user = User.find(params[:user_id])
    end
end