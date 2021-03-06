Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users, :controllers => {
                       :registrations => "users/registrations",
                       :sessions => "users/sessions",
                     }

  devise_scope :user do
    get "users/:id/edit" => "users/registrations#edit", as: :edit_other_user_registration
    match "users/:id", to: "users/registrations#update", via: [:patch, :put], as: :other_user_registration
    delete "users/:id/destroy", to: "users/registrations#destroy", as: :destroy_other_user_registration
  end

  # schedulesに関するrouteは全てJSフォーマット以外受け付けない(例外)
  # contact_groupsに関するrouteは全てJSフォーマット以外受け付けない(例外)
  # contact_group_relationsに関するrouteは全てJSフォーマット以外受け付けない(例外)
  # general_messagesに関するrouteはメッセージ読み込みアクションを除いて、JSフォーマット以外受け付けない(例外)
  # entriesに関するrouteは全てJSフォーマット以外受け付けない(例外)
  # room_messagesに関するrouteは全てJSフォーマット以外受け付けない(例外)

  root "homes#home"

  get "attendances" => "attendances#index"
  get "attendances/search" => "attendances#search", constraints: lambda { |req| req.xhr? && req.format == :js }
  get "attendances/csv_download" => "attendances#csv_download", constraints: lambda { |req| req.format == :csv }

  get "user/modal_search" => "users#modal_search", constraints: lambda { |req| req.xhr? && req.format == :js }
  get "user/search" => "users#search", constraints: lambda { |req| req.xhr? && req.format == :js }
  get "user/sidebar_search" => "users#sidebar_search", constraints: lambda { |req| req.xhr? && req.format == :js }
  get "users/modal_show/:id" => "users#modal_show", as: "user_modal_show", constraints: lambda { |req| req.xhr? && req.format == :js }

  get "general_messages/other_user_chat_ajax" => "general_messages#message_ajax", constraints: lambda { |req| req.xhr? }
  get "general_messages/home_chat_ajax" => "general_messages#home_message_ajax", constraints: lambda { |req| req.xhr? }

  get "schedules/meeting_new" => "schedules#meeting_new", constraints: lambda { |req| req.xhr? && req.format == :js }
  get "schedules/add_timer" => "schedules#add_timer", constraints: lambda { |req| req.xhr? && req.format == :js }
  get "schedules/date_change" => "schedules#date_change", constraints: lambda { |req| req.xhr? && req.format == :js }

  get "meeting_rooms/join/:id" => "meeting_rooms#join", as: "meeting_rooms_join", constraints: lambda { |req| req.xhr? && req.format == :js }
  get "meeting_rooms/past_index" => "meeting_rooms#past_index"

  post "general_messages/multiple_create" => "general_messages#multiple_create", constraints: lambda { |req| req.xhr? && req.format == :js }

  resources :attendances, only: [:create, :update], constraints: lambda { |req| req.xhr? && req.format == :js }
  resources :contact_group_relations, only: [:create], constraints: lambda { |req| req.xhr? && req.format == :js }
  resources :contact_groups, only: [:create, :destroy], constraints: lambda { |req| req.xhr? && req.format == :js }
  resources :departments, only: [:new, :create, :edit, :update, :destroy]
  resources :entries, only: [:create], constraints: lambda { |req| req.xhr? && req.format == :js }
  resources :general_messages, only: [:show, :create], constraints: lambda { |req| req.xhr? && req.format == :js }
  resources :schedules, only: [:new, :create, :edit, :update, :destroy], constraints: lambda { |req| req.xhr? && req.format == :js }
  resources :meeting_rooms, only: [:new, :create, :show, :index, :destroy]
  resources :room_messages, only: [:create], constraints: lambda { |req| req.xhr? && req.format == :js }
  resources :users, only: [:show, :index]
  resources :paid_holidays, only: [:create, :new]
end
