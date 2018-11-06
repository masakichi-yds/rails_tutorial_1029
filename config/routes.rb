Rails.application.routes.draw do

  get 'sessions/new'
  root 'static_pages#home'
  get '/help' => 'static_pages#help'
  get '/about' => 'static_pages#about'
  get '/contact' => 'static_pages#contact'

  get '/signup' => 'users#new'
  post '/signup' => 'users#create'
  resources :users
  #sersリソースのときは専用のresourcesメソッドを使って
  #RESTfulなルーティングを自動的にフルセットで利用できるようにしましたが、
  #Sessionリソースではフルセットはいらないので、「名前付きルーティング」だけを使います
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'
end
