class CommentsController < ApplicationController
  before_filter :authenticate_user!
  def show
    @comments = Comment.arrange(:order => :created_at,:conditions => {:slug => params[:id]})
  end

  def new
  end
  
  def create
    @comment = Comment.new(params[:comment])
    @comment.user_id = current_user[:id]
    if @comment.save
      redirect_to post_path(@comment.post_id)
    else
      redirect_to post_path(@comment.post_id)
    end
  end
end
