class InventoryAdjustment < ApplicationRecord
  belongs_to :item
  belongs_to :location
  validates_presence_of :external_transaction_id, :quantity, :uom_code, :transaction_code
  validates :transaction_code, inclusion: {in: %w(InventoryAdjustment InventoryCount),
                                           message: I18n.t('errors.messages.value_is_not_valid')}
end
