json.extract! supplier, :id, :no, :category, :group_by_color, :name, :sku, :active, :inactive, :link, :created_at, :updated_at
json.url supplier_url(supplier, format: :json)
