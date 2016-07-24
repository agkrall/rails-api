class CreateReasonCodes < ActiveRecord::Migration
  def change
    create_table :reason_codes, id: :uuid  do |t|
      t.string :code, null: false
      t.string :description, null: false
      t.timestamps null: false
    end
  end
end
