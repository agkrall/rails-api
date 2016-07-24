class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes, id: :uuid  do |t|
      t.string :name, null: false
      t.string :attribute_type, null: false
      t.timestamps null: false
    end
  end
end
