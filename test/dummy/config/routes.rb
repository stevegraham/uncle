Dummy::Application.routes.draw do
  resources :widgets, except: %i<new edit> do
    resources :gizmos, except: %i<new edit>
    resources :doo_dads, except: %i<new edit>
  end

  resources :thingies, except: %i<new edit>
end
