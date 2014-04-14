Dummy::Application.routes.draw do
  root 'widgets#show'
  EXCLUDED_ACTIONS = %i<new edit>.freeze

  resources :widgets, except: EXCLUDED_ACTIONS do
    resources :gizmos, except: EXCLUDED_ACTIONS
    resources :doo_dads, except: EXCLUDED_ACTIONS
  end

  resources :thingies, except: EXCLUDED_ACTIONS

  resource :user, except: EXCLUDED_ACTIONS do
    resource :profile, controller: 'thingies'
  end
end
