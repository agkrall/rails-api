class InventoryHold < ApplicationRecord
  belongs_to :item
  belongs_to :location
  has_and_belongs_to_many :hold_codes
  validates_presence_of :external_transaction_id, :quantity, :uom_code
end