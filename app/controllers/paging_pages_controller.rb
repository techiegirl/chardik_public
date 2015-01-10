class PagingPagesController < ApplicationController
  layout :false
  require 'uri'
  require "cgi"
  require 'date'
  NLP_SERVER_ADDRESS = "54.243.235.139"
  NLP_SERVER_PORT = 9090
  NLP_SERVER_CONNECTION_TIMEOUT = 10.seconds
  POSTS_PER_PAGE = 5
  
  include PagingPagesHelper
  include ActionView::Helpers::DateHelper
  def following
    @follow_users = current_user.following_users.order("username").page(params[:page]).per(10)
    respond_to do |format|
        format.html
        format.js
    end  
  end

  def followers
    @follow_users = current_user.user_followers.order("username").page(params[:page]).per(10)
    respond_to do |format|
        format.html
        format.js
    end
  end
  
  def followers_big
    @follow_big_users = current_user.user_followers.order("username").page(params[:page]).per(10)
    respond_to do |format|
        format.html
        format.js
    end
  end
  
  def following_big
    @follow_big_users = current_user.following_users.order("username").page(params[:page]).per(10)
    respond_to do |format|
        format.html
        format.js
    end  
  end
  
  def search
    @posts = Post.page(params[:page]).per(3).order("created_at desc")
    respond_to do |format|
        format.html
        format.js
    end
  end
  
  def news
    #@post_news = Post.page(params[:page]).per(1)
    post = Post.find(:all, :conditions => {:user_id => current_user.following_users, :anonymous => 0}, :order => "created_at desc")
    @post_news = Kaminari.paginate_array(post).page(params[:page]).per(5)
    @special_post = post.first
    respond_to do |format|
        format.html
        format.js
    end
  end
  
  def news_polling
    if params['post_special'].blank?
      @post_user = ""
      @post_news = Post.where("id > ? and created_at > ? and anonymous = ? and user_id IN (?)", params[:post_id], Time.at(params[:post_date].to_i),0,current_user.following_users.map{|f| f.id}).order('created_at DESC')
      #@post_news = @post_news.sort_by(&:created_at )
    else
      @post_user = params["post_special"]
      @post_news = Post.where("id > ? and created_at > ? and anonymous = ? and user_id = ? ", params[:post_id], Time.at(params[:post_date].to_i),0,params['post_special']).order('created_at DESC')
      #@post_news = @post_news.sort_by(&:created_at)
    end
    respond_to do |format|
        format.html
        format.js
    end
  end
  
  def news_user
    post = Post.find(:all, :conditions => {:anonymous => 0, :user_id => params[:id]}, :order => "created_at desc")
    @post_user = params[:id]
    @post_news = Kaminari.paginate_array(post).page(params[:page]).per(5)
    respond_to do |format|
        format.html
        format.js
    end
  end
  
  def related_post
    @failed = false
    query_value = params[:title]
    query_value = "I am free" if query_value.blank?
    begin
      transport = Thrift::BufferedTransport.new(Thrift::Socket.new(NLP_SERVER_ADDRESS, NLP_SERVER_PORT, NLP_SERVER_CONNECTION_TIMEOUT))
      protocol = Thrift::BinaryProtocol.new(transport)
      client = NLPService::Client.new(protocol)

      transport.open()
      page = params[:page].blank? ? 0 : params[:page].to_i - 1
      # Run a remote calculation
      # "type"=>"hahaha", "text"=>"hahaha", "totalPages"=>2, "currentPage"=>1
      @result = client.getAllPostsForResult(query_value, page, POSTS_PER_PAGE)  #it accessing the ruby server program method calc via thrift service
          #Run a Async call
      #client.run_task()

      transport.close()
      @result = JSON.parse(@result)


      @current_page = @result['currentPage']
      @total_pages = @result['totalPages']
      @title_text = @result['text']
      @r = []

      @result['detailDataPage'].each do |a|
        x = {}
        user = User.find_by_username(a[1])
        if user.blank?
          x['image_url'] = 'assets/user.png'
          x['user_id'] = ""
          x['username'] = "Anonymous"
          x['post'] = a[0]
          x['post_at'] = time_ago_in_words(DateTime.parse(a[2]))
          x['page_link'] = ""
          @r << x
        else
          x['image_url'] = user.avatar_url
          x['user_id'] = user.id
          x['username'] = a[1]
          x['post'] = a[0]
          x['post_at'] = time_ago_in_words(DateTime.parse(a[2]))
          x['page_link'] = page_link(user.id)
          @r << x
        end
      end

      @r = @r.to_json
    rescue
      @failed = true
      @result = SERVER_ERROR_MESSAGE
    end
    #Rails.logger.warn @result.inspect

    #url = URI(request.fullpath)
    #p = CGI.parse(url.query)
    # queries = params[:title].split(" ")
    #     ids = []
    #     queries.each do |q|
    #       p = Post.find(:all, :conditions => ["title like ?", "%#{q}%"])
    #       ids += p.map{|a| a.id}
    #     end
    # post = Post.find(ids)
    #post = Post.find(:all, :conditions => p)
    # post = Post.find(:all, :conditions => ["title like ?", "%#{params[:title]}%"])
    # @related_posts = Kaminari.paginate_array(post).page(params[:page]).per(3)
    respond_to do |format|
      format.html
      format.js
    end
  end
end
