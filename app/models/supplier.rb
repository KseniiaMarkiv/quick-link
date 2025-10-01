class Supplier < ApplicationRecord
  validates :sku, presence: true
end
