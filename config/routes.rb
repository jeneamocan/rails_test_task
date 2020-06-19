Rails.application.routes.draw do
  devise_for :customers, controllers: { registrations: "customers/registrations" }

  resources :logins, only: :index do
    get "/", to: "logins#show"
  end

  get "/accounts/:account_id", to: "accounts#show", as: "account"

  post   "create_connection",  to: "logins#create",    as: "create_connection"
  delete "destroy_connection", to: "logins#destroy",   as: "destroy_connection"
  put    "reconnect",          to: "logins#reconnect", as: "reconnect"
  put    "refresh",            to: "logins#refresh",   as: "refresh"
  get    "success",            to: "logins#success",   as: "success"

  root "logins#index"
end
