class CreateInventoryCount
  def initialize(item, location, quantity, external_transaction_id, uom_code)
    @item = item
    @location = location
    @quantity = quantity
    @external_transaction_id = external_transaction_id
    @uom_code = uom_code
  end

  def run
    inventory_adjustment = InventoryAdjustment.create(item: @item,
                                                      location: @location,
                                                      quantity: @quantity - retrieve_stock_on_hand,
                                                      external_transaction_id: @external_transaction_id,
                                                      uom_code: @uom_code,
                                                      transaction_code: 'InventoryCount')
    InventoryCount.create(inventory_adjustment: inventory_adjustment, quantity: @quantity)
  end

  private
  def retrieve_stock_on_hand
    use_case = RetrieveStockOnHand.new(@item, @location)
    use_case.run
    use_case.stock_on_hand
  end
end
