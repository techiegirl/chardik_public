class VotesController < ApplicationController
  before_filter :authenticate_user!
  def voteup
    type = params[:type]
    id = params[:id]
    if type == "Post"
      @vote = Post.find(id)
    else
      @vote = Comment.find(id)
    end
    @vote.liked_by current_user
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def votedown
    type = params[:type]
    id = params[:id]
    if type == "Post"
      @vote = Post.find(id)
    else
      @vote = Comment.find(id)
    end
    @vote.disliked_by current_user
    respond_to do |format|
      format.html
      format.js
    end
  end
end
