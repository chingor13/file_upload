FileUpload::Engine.routes.draw do
  resources :redis_files, only: [:index, :new, :create, :show, :destroy] do
    post :bulk, on: :collection
  end
end
