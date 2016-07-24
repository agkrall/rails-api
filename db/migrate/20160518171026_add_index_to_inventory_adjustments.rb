class AddIndexToInventoryAdjustments < ActiveRecord::Migration
  def change
    add_index(:inventory_adjustments, [:item_id, :location_id], unique: false)
  end
end
