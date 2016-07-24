class CreateInventoryHolds < ActiveRecord::Migration
  def change
    create_table :inventory_holds, id: :uuid do |t|
      t.string :external_transaction_id, null: false
      t.uuid :item_id, null: false
      t.uuid :location_id, null: false
      t.decimal :quantity, null: false
      t.string :uom_code, null: false
      t.timestamps null: false
    end

    add_foreign_key :inventory_holds, :items
    add_foreign_key :inventory_holds, :locations

    create_table :hold_codes, id: :uuid do |t|
      t.string :code, null: false
      t.timestamps null: false
    end

    create_table :hold_codes_inventory_holds do |t|
      t.uuid :inventory_hold_id, null: false
      t.uuid :hold_code_id, null: false
    end

    add_foreign_key :hold_codes_inventory_holds, :inventory_holds
    add_foreign_key :hold_codes_inventory_holds, :hold_codes
  end
end
