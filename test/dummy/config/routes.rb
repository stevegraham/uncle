Dummy::Application.routes.draw do
  resources :widgets do
    resources :gizmos
    resources :doo_dads
  end
end
