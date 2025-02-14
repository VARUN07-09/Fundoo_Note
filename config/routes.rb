Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      # User-related routes
      post 'register', to: 'users#register'
      post 'login', to: 'users#login'
   
      post 'forgot_password', to: 'users#forgot_password'
      post 'reset_password', to: 'users#reset_password' 
      get  'profile', to: 'users#profile'

        
      # Notes-related routes
      post 'notes/create', to: 'notes#create'                 # Create a new note
      get  'notes', to: 'notes#index'                         # Get all notes for a user
      get  'notes/:id', to: 'notes#show'                      # Get note by ID
      put  'notes/:id/update', to: 'notes#update'             # Update a note
      post 'notes/:id/trash', to: 'notes#trash'               # Toggle trash status
      post 'notes/:id/archive', to: 'notes#archive'           # Toggle archive status
      post 'notes/:id/change_color', to: 'notes#change_color' # Change note color

    
    end
  end
end
