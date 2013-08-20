Rails.application.routes.draw do
  mount FileUpload::Engine => "/file_upload"
  resources :users
  resources :emails

  get "/db_files/:id/:name", to: "db_files#show"
end
