class CreateForeignKeysOnInventoryAdjustment < ActiveRecord::Migration
  def change
    remove_column :inventory_adjustments, :item_id
    remove_column :inventory_adjustments, :location_id
    add_column :inventory_adjustments, :item_id, :uuid, null: false
    add_column :inventory_adjustments, :location_id, :uuid, null: false
    add_foreign_key :inventory_adjustments, :items
    add_foreign_key :inventory_adjustments, :locations
  end
end
