class ProfileController < ApplicationController
  before_filter :authenticate_user!
  def index
    @body_class = "feed_container"
    @user = User.find_by_username(params[:id])
    if !@user.blank?
      post = Post.find(:all, :conditions => {:anonymous => 0, :user_id => @user.id}, :order => "created_at desc")
      @post_user = params[:id]
      @post_news = Kaminari.paginate_array(post).page(params[:page]).per(5)
    else
      render_404
    end

    respond_to do |format|
      format.html
      format.js
    end
  end
end