Rails.application.routes.draw do
  root "suppliers#index"

  resources :suppliers do
    collection do
      get  :import_form          # /suppliers/import_form
      post :import_from_excel    # /suppliers/import_from_excel
      get  :download_xlsx        # /suppliers/download_xlsx
    end
  end
end
