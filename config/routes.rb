FileUpload::Engine.routes.draw do
  resources :redis_files do
    post :bulk, on: :collection
  end
end
