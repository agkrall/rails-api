class CreateItems < ActiveRecord::Migration
  def change
    create_table :items, id: :uuid  do |t|
      t.string :external_id, null: false
      t.timestamps null: false
    end
  end
end
