Chardik::Application.routes.draw do
  #match 'messages', :controller => :messages, :action => 'index'
  authenticated :user do
    root :to => "posts#index"
  end
  unauthenticated :user do
    devise_scope :user do
      get "/" => "devise/sessions#new"
    end
  end

  resources :comments
  resources :paging_pages do
    collection do
      get 'following'
      get 'followers'
      get 'search'
      get 'news'
      get 'related_post'
      get 'followers_big'
      get 'following_big'
      get 'news_polling'
    end
    
    member do
      get 'news_user'
    end
  end
  resources :posts do
    collection do
      get :follow
      get :auto_post
      get :autocomplete
      get :callback
      get :create_discussion
      get :your_followers
      get :your_following
    end
  end
  match "topics/:id", :controller => :posts, :action => :show, :as => "topic"
  match "about", :controller => :about, :action => :index
  match "terms", :controller => :about, :action => :terms
  match "privacy", :controller => :about, :action => :privacy

  devise_for :users
  devise_scope :user do
    match "/" => "devise/sessions#new"
    match '/logout' => "devise/sessions#destroy"
    match '/edit_profile' => "devise/registrations#edit"
  end
  
  match 'chart' => 'posts#show_chart'

  resources :users, :except => [:new, :create, :index] do
    resources :messages do
      collection do
        get :get_user_message
        get :get_inbox
        get :get_outbox
        get :delete_message
        get :message_read
      end
    end
  end

  resources :votes do 
    collection do
    end
  end
  match "vote_up/:id/:type", :controller => "votes", :action => :voteup, :as => "voteup"
  match "vote_down/:id/:type", :controller => "votes", :action => :votedown, :as => "votedown"
  match "messages", :controller => :messages, :action => :index
  match "messages/create", :controller => :messages, :action => :create

  get ':id/:page', :controller => :profile, :action => :index
  get ':id/', :controller => :profile, :action => :index

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
