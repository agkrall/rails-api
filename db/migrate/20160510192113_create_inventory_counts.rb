class CreateInventoryCounts < ActiveRecord::Migration
  def change
    create_table :inventory_counts, id: :uuid  do |t|
      t.uuid :inventory_adjustment_id, index: true, null: false
      t.decimal :quantity, null: false
      t.timestamps null: false
    end

    add_foreign_key :inventory_counts, :inventory_adjustments
  end
end
