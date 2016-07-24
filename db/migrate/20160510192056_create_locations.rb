class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations, id: :uuid  do |t|
      t.string :external_id, null: false
      t.timestamps null: false
    end
  end
end
