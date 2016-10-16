Rails.application.routes.draw do
  get 'posts/index'

  get 'posts/new'

  get 'posts/show'

  get 'posts/edit'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
