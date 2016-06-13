Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
    get '/dailyrolluptime'   => 'dailyrolluptime#index'
	get '/server'            => 'server#index'
	get '/performance'       => 'rollup_performance#index'
    get '/rollupmatic'       => 'mecinformation#index'
	get '/error'             => 'error#index'
	get '/meticstwo'         => 'meticstwo#index'
	get '/cpm'               => 'cpm#index'
	get '/fileloading'       => 'fileloading#index'
    get '/fileloadingone'    => 'fileloadingone#index'
	get '/ranalytic'         => 'rollupanalytic#index'
	get '/fileloading'       => 'fileloading#index'
	get '/bdsticket'         => 'bdsticket#index'
	get '/cmbfx'             => 'cmbfx#index' 
	get '/MECAvailable'      => 'mec_available#index'
	get '/slabreach1'        => 'slabreach#index'
	get '/slabreach2'        => 'slabreach#index1'
	get '/slabreach'         => 'slabreach#index3'
	get '/slabreach3'         => 'slabreach#index4'
	get '/cpmdetail'         => 'cpmdetail#index'
	get '/yottatrend'        => 'yottatrend#index'
    get '/EventIDList'       => 'event_id_list#index'
	get '/seaquesttrend'     => 'seaquesttrend#index'
	get '/uamtrend'          => 'uamtrend#index'
	get '/dqtrend'           => 'dqtrend#index'
	get '/cmtrend'           => 'cmtrend#index'
	get '/postdata'          => 'postdata#index'
	get '/devoncalltrend'    => 'devoncalltrend#index'
	get '/midmtimtpinfo'     => 'midmtimtpinfo#index'
	get '/onboardtrend'      => 'onboardtrend#index'
	get '/releasetrend'      => 'releasetrend#index'
    get '/rollupbyportfolio' => 'rollupbyportfolio#index'
    get '/dqbyassignee'              => 'dqbyasignee#index'
    get '/edwoptimizationtrend'      => 'edwoptimizationtrend#index'
    get '/rollupbyearlyportfolio'    => 'rollupbyearlyportfolio#index'
    get '/permanenttrend'            => 'permanent#index'
    get '/optimizationtrend'         => 'optimization#index'
    get '/midinformation'         => 'midinformation#index'

    
	
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
