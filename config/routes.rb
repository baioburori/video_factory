VideoFactory::Application.routes.draw do
  resources :image_urls


  get "api/list"

  get "hello_world/index"

  get "videos/list"

  get "videos/video_list_api"
  get "videos/index"
  get "videos/encode"
  get "videos/player"
  get "videos/detail"
  get "videos/delete"
  get "videos/sleep"

  # match 'videos/detail/:escaped_name' => 'videos#detail', constraints: { escaped_name: /[^\/]+/ }
  # match 'videos/encode/:name/:format' => 'videos#encode', constraints: { name: /[^\/]+/ }
  # match 'videos/player/:name' => 'videos#player'
  # match 'videos/delete/:escaped_name' => 'videos#delete', constraints: { escaped_name: /[^\/]+/ }
  get 'videos/detail/:escaped_name' => 'videos#detail', constraints: { escaped_name: /[^\/]+/ }
  get 'videos/encode/:name/:format' => 'videos#encode', constraints: { name: /[^\/]+/ }
  get 'videos/player/:name' => 'videos#player'
  get 'videos/delete/:escaped_name' => 'videos#delete', constraints: { escaped_name: /[^\/]+/ }

  get 'videos/db' => 'videos#db'
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
