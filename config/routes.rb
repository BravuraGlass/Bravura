Rails.application.routes.draw do

  resources :working_logs, only: :index do
    collection do
      post 'checkin'
      get 'checkin_barcode'
      get 'checkout_barcode'
      post 'checkout'
      get 'destroy_all'
      get 'report'
      delete 'destroy_report'
      get 'report_detail'
      get 'edit_report_detail'
      post 'update_report_detail'
      get 'new_report_detail'
      post 'create_report_detail'
    end
  end
  
  resources :dashboard, only: :index do
    collection do
      ["forders_detail","sections_detail", "jobs_detail"].each do |act|
        get act
      end  
    end
  end
  
  resources :product_types
  resources :status_checklist_items
  resources :statuses
  resources :tasks
  resources :employees
  resources :users do
    member do
      get "revoke"
    end  
  end
  resources :customers

  resources :fabrication_orders, only: [:index, :new, :edit, :update, :destroy] do
    collection do
      get 'addresses'
    end
    
    resources :rooms, only: [:new, :edit, :update, :destroy, :clone] do
      collection do
        post 'clone'
        get 'list'
      end  
      resources :products, only: [:new, :edit, :update, :destroy] do
        resources :product_sections, only: [:new, :edit, :update, :destroy]
      end
    end
    resources :products, only: [:create]
  end
  
  resources :rooms, only: [:update] do
    collection do 
      get 'available_statuses'
    end  
    
    member do
      post 'update_status'
    end
    
    resources :products, only: [:update] do
      collection do
        get 'tasks'
      end  
    end   
  end
  
  resources :products, only: [:update] do
    collection do
      get 'available_task_statuses'
    end
    
    member do
      post 'update_task_status'
    end
  end

  resources :product_sections, only: [:update] do
    collection do
      post 'barcodes_print'
    end
    
    member do
      get 'barcode'
    end  
  end   

  resources :jobs, only: [:index, :new, :create, :update, :destroy] do
    member do
      get 'product_detail'
    end  
    resources :comments
    resources :fabrication_orders, only: [:create, :show]
  end

  delete 'jobs/:id/image/:picture_id' => "jobs#destroy_image", :as => 'delete_image'
  post 'jobs/:id/image/' => "jobs#add_image", :as => 'add_image'

  get 'dashboard' => "jobs#dashboard", :as => 'dashboard'

  get "jobs/:id" => "jobs#index", :as => 'select_job'
  get 'map/index', :as => 'map_index'
  post 'sessions/create',  :defaults => { :format => 'html' }
  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"

  ["f","r","p","s"].each do |var|
      get "#{var}_orders_barcode/:id" => "fabrication_orders##{var}_orders_barcode", :as => "#{var}_orders_barcode", :defaults => { :format => 'html' }  
  end  
  
  get "f_orders_qr/:id" => "fabrication_orders#f_orders_qr", :as => 'f_orders_qr', :defaults => { :format => 'html' }
  get "r_orders_qr/:id" => "fabrication_orders#r_orders_qr", :as => 'r_orders_qr', :defaults => { :format => 'html' }
  get "p_orders_qr/:id" => "fabrication_orders#p_orders_qr", :as => 'p_orders_qr', :defaults => { :format => 'html' }
  get "s_orders_qr/:id" => "fabrication_orders#s_orders_qr", :as => 's_orders_qr', :defaults => { :format => 'html' }
  get "update_status/:id" => "product_sections#update_status", :as => 'update_status'
  get "edit_section_status/:id/:new_status(.:format)" => "product_sections#edit_section_status", :as => 'edit_section_status'
  post "edit_section_status/multiple(.:format)" => "product_sections#multiple_edit_section_status", :as => 'multiple_edit_section_status'
  post "edit_section_status/:id(.:format)" => "product_sections#edit_section_status", :as => 'post_edit_section_status'
  get 'search' => 'searches#search'




  root :to => "sessions#new"

end
