class CreateObjectAttributes < ActiveRecord::Migration
  def change
    create_table :object_attributes, id: :uuid do |t|
      t.uuid :object_id, null: false
      t.uuid :attribute_id, null: false
      t.string :value, null: false
      t.timestamp :effective_date, null: false
      t.timestamp :end_date
      t.timestamps null: false
    end

    add_foreign_key(:object_attributes, :attributes, name: 'object_attr_attr_fk')
  end
end
