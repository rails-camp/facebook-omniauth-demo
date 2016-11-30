Rails.application.routes.draw do
  get 'pages/about'

  get 'pages/secretstuff'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: 'pages#home'
end
