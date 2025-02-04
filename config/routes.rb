# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: "auth", skip: [:registrations]

  as :user do
    get "change_password/edit" => "devise/registrations#edit", as: "edit_user_registration"
    patch "change_password" => "devise/registrations#update", as: "user_registration"
  end

  resources :users do
    get "reinvite", on: :member
  end

  resources :regimes, only: [] do
    resources :permit_categories  # , only: [:index]
    resources :permit_categories_lookup, only: [:index]
    resources :transactions, only: %i[index show edit update] do
      put "approve", on: :collection
      get "audit", on: :member
    end
    resources :history, only: %i[index show]
    resources :retrospectives, only: %i[index show]
    resources :exclusions, only: [:index]
    resources :transaction_files, only: %i[index create]
    resources :imported_transaction_files, only: %i[index show edit update]
    resources :transaction_summary, only: %i[index show]
    resources :retrospective_files, only: [:create]
    resources :retrospective_summary, only: [:index]
    resources :annual_billing_data_files, only: %i[index show]
    resources :exclusion_reasons, except: [:show]
    resources :data_export, only: [:index] do
      get "download", on: :collection
    end
  end

  get "/jobs/import", to: "jobs#import", as: :jobs_import
  get "/jobs/export", to: "jobs#export", as: :jobs_export
  get "/jobs/data", to: "jobs#data", as: :jobs_data

  get "/last-email",
      to: "last_email#show",
      as: "last_email",
      constraints: ->(_request) { ENV.fetch("TCM_ENVIRONMENT", "production") != "production" }

  get "/clean",
      to: "clean#show",
      as: "clean",
      constraints: ->(_request) { ENV.fetch("TCM_ENVIRONMENT", "production") != "production" }

  root to: "transactions#index"

  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
