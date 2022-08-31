Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'maps#index'
  # get '*path', to: 'home#index'

  get 'maps' => 'maps#index'
  post 'maps' => 'maps#fetch_map_api'

  get 'calendars' => 'calendars#index'

  get 'calendars/mail' => 'calendars#mail'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
