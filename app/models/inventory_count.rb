class InventoryCount < ApplicationRecord
  belongs_to :inventory_adjustment
  validates_presence_of :quantity
end