class CreateInventoryTransaction
  attr_reader :errors
  attr_reader :inventory_transaction

  def initialize(external_transaction_id, item, location, quantity, uom_code)
    @external_transaction_id = external_transaction_id
    @item = item
    @location = location
    @quantity = quantity
    @uom_code = uom_code
  end

  def run
    inventory_transaction = InventoryAdjustment.create(external_transaction_id: @external_transaction_id,
                                                       item: @item,
                                                       location: @location,
                                                       quantity: @quantity,
                                                       uom_code: @uom_code,
                                                       transaction_code: 'InventoryAdjustment')

    if inventory_transaction.errors.empty?
      @inventory_transaction = inventory_transaction
    else
      @errors = inventory_transaction.errors.to_h
      false
    end
  end
end
