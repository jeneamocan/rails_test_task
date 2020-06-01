Rails.application.routes.draw do
  devise_for :customers, controllers: { registrations: "customers/registrations" }
  get "home", to: "logins#index", as: "home"

  authenticated :customer do
    root "logins#index"
    get  "success" => "logins#success_callback"

    resources :logins
    resources :accounts

    get    "create_connection", to: "logins#create_connection", as: "create_connection"
    delete "destroy_login",     to: "logins#destroy_login",     as: "destroy_login"
    get    "fetch_logins",      to: "logins#fetch_logins",      as: "list_logins"
    post   "save_login",        to: "logins#save_login",        as: "save_login"
    put    "reconnect_login",   to: "logins#reconnect_login",   as: "reconnect_login"
    put    "refresh_login",     to: "logins#refresh_login",     as: "refresh_login"
    get    "fetch",             to: "accounts#fetch",           as: "fetch"
  end
end
