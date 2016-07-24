class AddSohIndicatorToReasonCodes < ActiveRecord::Migration
  def change
    add_column :reason_codes, :impacts_soh, :boolean, null: false
  end
end
