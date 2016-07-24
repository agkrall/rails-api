class CreateInventoryAdjustments < ActiveRecord::Migration
  def change
    create_table :inventory_adjustments, id: :uuid  do |t|
      t.string :external_transaction_id, null: false
      t.string :item_id, null: false
      t.string :location_id, null: false
      t.decimal :quantity, null: false
      t.string :uom_code, null: false
      t.string :transaction_code, null: false
      t.timestamps null: false
    end
  end
end
