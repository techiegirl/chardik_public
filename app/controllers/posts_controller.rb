class PostsController < ApplicationController
  include PostsHelper
  before_filter :authenticate_user!, :except => [:show]
  #caches_page :index, :callback, :cache_path => Proc.new { |controller| controller.params }, :if => proc { |controller| controller.request.xhr? }
  NLP_SERVER_ADDRESS = "54.243.235.139"
  NLP_SERVER_PORT = 9090
  NLP_SERVER_CONNECTION_TIMEOUT = 10.seconds
  AGE_GROUPS = ["Below 18", "18-22", "23-27", "28-32", "33-37", "38-42", "43-47", "48-52", "53-57", "Above 57"]
  AGE_GROUPS_SIZE = 10; MIN_AGE = 18; MAX_AGE = 57; AGE_RANGE = 5;
  MAX_COUNTY_COUNT = 10
  def index
    @post_result = params[:result].blank? ?  nil : params[:result].to_s
    @post_new = Post.new
    @user = current_user
  end
  
  def show
    @post = Post.find(params[:id])
    if request.path != topic_path(@post)
      return redirect_to topic_path(@post), :status => :moved_permanently
    end
    @post.comments.build
    #@comments = Comment.all(:conditions => {:post_id => @post})
    @comments = Comment.arrange(:order => :created_at,:conditions => {:post_id => @post})
    @comment_new = Comment.new
  end
  
  def home
    
  end
  
  def new
    
  end
  
  def auto_post
    @text = '[{"pos":"'+params[:query]+'"}]'
    respond_to do |format|
      format.html
      format.json { render :json => @text }
    end
  end
  
  def create
    @post = Post.new(params[:post])
    @post.user_id = current_user[:id]
    if @post.save
      #call to backend API here and post back to browser
      respond_to do |format|
        format.json { render :json => "test callback"}
      end
    else
      redirect_to root_path
    end
  end
  
  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(params[:post])
      redirect_to post_path(@post)
    else
      redirect_to post_path(@post)
    end
  end
  
  def autocomplete
    #query_value = params[:postPrefix]
    query_value = params[:term]
    # query_value cannot be empty
    # query_value = "I am free" if query_value.blank?
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new(NLP_SERVER_ADDRESS, NLP_SERVER_PORT, NLP_SERVER_CONNECTION_TIMEOUT))
    protocol = Thrift::BinaryProtocol.new(transport)
    client = NLPService::Client.new(protocol)

    transport.open()

    # Run a remote calculation
    # result = client.autoSuggestPostsForPrefix(query_value, 5)  #it accessing the ruby server program method calc via thrift service
    @result = client.autoSuggestPostsForPrefix(query_value, 5)
    #Run a Async call
    #client.run_task()

    transport.close()
    render :json => @result
    #@posts = Post.order(:title).where("title like ?", "%#{params[:term]}%")
    #render json: @posts.map(&:title)
  end
  
  def callback
    @failed = false
    find_post = Post.find_by_user_id_and_title(current_user.id,params[:post][:title])
    #@post = Post.find_or_create_by_user_id_and_title(current_user.id,params[:post][:title])
    if find_post.blank?
      @post = Post.new(params[:post])
      @post.user_id = current_user.id
      @post.save
    else
      @post = find_post
      @post.update_attributes({:updated_at => Time.now})
    end
    #@post = Post.new(params[:post])
    #@post.user_id = current_user.id
    #@post.save
    # #@posts = Post.all.to_json
    #     # call API here with params[:post][:title]
    @title = (params[:post][:title].blank? ? "test" : params[:post][:title])
    #     @posts = "[
    #       {'result_sentence': '200 people will buy an iphone', 'comment_string': 'buy-an-iphone', 'search_string': 'buy an iphone', 'start_or_join': '#{start_or_join('buy-an-iphone')}'},
    #       {'result_sentence': '200 people will buy an ipad', 'comment_string': 'buy-an-ipad', 'search_string': 'buy an ipad', 'start_or_join': '#{start_or_join('buy-an-ipad')}'},
    #       {'result_sentence': '200 people will buy an ipod', 'comment_string': 'buy-an-ipod', 'search_string': 'buy an ipod', 'start_or_join': '#{start_or_join('buy-an-ipod')}'}
    #       ]"
    # query_value = params[:value]
    query_value = params[:post][:title]
    unless query_value.blank?
      begin
        transport = Thrift::BufferedTransport.new(Thrift::Socket.new(NLP_SERVER_ADDRESS, NLP_SERVER_PORT, NLP_SERVER_CONNECTION_TIMEOUT))
        protocol = Thrift::BinaryProtocol.new(transport)
        client = NLPService::Client.new(protocol)
        transport.open()
        # Run a remote calculation
        @result = client.processUserPost(query_value, @post[:id], params[:post][:anonymous] == "1" ? "$Anonymous" : current_user.username, find_post.blank? ? false : true)  #it accessing the ruby server program method calc via thrift service
        #Run a Async call
        #client.run_task()
        transport.close()
        @result = JSON.parse(@result)
        @result = @result.each do |k|
          k['commentString'] = k['searchString'].downcase
          k['start_or_join'] = start_or_join(k['commentString'])
        end
        Rails.logger.warn @result.inspect
        @result = @result.to_json
      rescue
        @failed = true
        @result = SERVER_ERROR_MESSAGE
      end
    end
    #@result.each{|r| Rails.logger.warn r.inspect }
    # render :json => result#"[{\"result\":\"1 people want to fly\",\"searchString\":\"I want to fly\"}, {\"result\":\"2 people want to\",\"searchString\":\"I want to\"},{\"result\":\"1 people want to fly\",\"searchString\":\"I want to fly\"}, {\"result\":\"1 people want to fly\",\"searchString\":\"I want to fly\"}, {\"result\":\"1 people want to fly\",\"searchString\":\"I want to fly\"}]"
    respond_to do |format|
      format.html {render :text => "This is Test"}
      format.js
    end
  end
  
  def create_discussion
    @post = Post.find_or_create_by_title(params[:title])
    @post.user = current_user
    if @post.save
      redirect_to @post
    else
      redirect_to :back
    end
  end
  
  def follow
    @user_follow = User.find(params[:user])
    if current_user.following?(@user_follow)
      current_user.stop_following(@user_follow)
    else
      current_user.follow(@user_follow)
    end
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def your_followers
    
  end
  
  def your_following
    
  end

  def show_chart
    @failed = false; is_age_chart = false; result = []; user_names = []; total =0; post_ids = []
    chart_by_label = params[:chartBy].downcase; chartBy = params[:chartBy].downcase
    user_post_info = get_thrift_results(params[:user_post])
    user_post_info = JSON.parse(user_post_info)
    chart_title = "Chart By #{chart_by_label.capitalize}"
    is_country_chart = false
    is_country_chart = true if params[:chartBy].downcase == 'country'
    if chartBy == 'age'
      chartBy = 'birthday' if chartBy == 'age'
      is_age_chart = true
    end

    user_post_info.each {|r| r.each {|k, v| post_ids << v } }
    User.select(:username).where(:id => Post.select(:user_id).where(:id => post_ids)).map {|x| user_names << x.username}
    get_chart_by_username = User.get_group_by_results(chartBy, user_names)
    get_chart_by_username.each {|d| result << [d.send(chartBy), d.count ] }
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string')
    data_table.new_column('number')
    #result = [['BD', 5], ['CA', 2], ['LA', 1],['DD', 6], ['FF', 10], ['KK', 8],  ['GG', 3], ['NN', 14]]
    if !result.blank?
      if is_age_chart
        Hash[result.map!{ |k, v| [age(k), v] }]
        result = create_age_group(result)
      else is_country_chart
        result = result.sort_by {|x| x[1]}.reverse
        if result.length > MAX_COUNTY_COUNT
          result[MAX_COUNTY_COUNT..result.length].each do |r|
            total += r[1]
          end
          result[MAX_COUNTY_COUNT] = ['Other', total]
        end
      end
      result.each do |r|
        label = r[0]
        data_table.add_row([label, r[1]])
      end
      option = { :width => 400, :height=> 220, :title => chart_title}
      @chart = GoogleVisualr::Interactive::PieChart.new(data_table, option)
      @param_index = params[:index]
    else
      @failed = true
    end

    render :partial => 'chart', :layout => false
  end

  def get_thrift_results(user_post)
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new(NLP_SERVER_ADDRESS, NLP_SERVER_PORT, NLP_SERVER_CONNECTION_TIMEOUT))
    protocol = Thrift::BinaryProtocol.new(transport)
    client = NLPService::Client.new(protocol)

    transport.open()
    user_post_info = client.getUserAndPostInfoForResult(user_post)
    transport.close()
    return user_post_info
  end

  def age(dob)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def create_age_group(ages_and_counts)
    groups = []; age_group_results = []
    (0..AGE_GROUPS_SIZE-1).each {|i| groups[i]=0}

    ages_and_counts.each do |r|
      age = r[0]; count = r[1];

      if age < MIN_AGE
        groups[0] = groups[0] + count
      elsif age > MAX_AGE
        groups[AGE_GROUPS_SIZE - 1] = groups[AGE_GROUPS_SIZE - 1] + count
      else
        temp_age = age - MIN_AGE;
        id = temp_age / AGE_RANGE + 1
        groups[id] = groups[id] + count
      end
    end

    AGE_GROUPS.each_with_index do |g, i|
      age_group_results << [g, groups[i]]
    end

    return age_group_results
  end

end
