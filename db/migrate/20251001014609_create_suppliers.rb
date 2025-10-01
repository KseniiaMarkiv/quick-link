class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.integer :no
      t.string :category
      t.string :group_by_color
      t.string :name
      t.string :sku
      t.boolean :active
      t.boolean :inactive
      t.string :link

      t.timestamps
    end
  end
end
