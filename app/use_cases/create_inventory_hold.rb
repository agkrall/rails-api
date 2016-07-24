class CreateInventoryHold
  attr_reader :inventory_hold, :errors

  def initialize(external_transaction_id, item, location, quantity, uom_code, hold_codes)
    @external_transaction_id = external_transaction_id
    @item = item
    @location = location
    @quantity = quantity
    @uom_code = uom_code
    @hold_codes = hold_codes
  end

  def run
    inventory_hold = InventoryHold.new(external_transaction_id: @external_transaction_id,
                                          item: @item,
                                          location: @location,
                                          quantity: @quantity,
                                          uom_code: @uom_code,
                                          hold_codes: @hold_codes)
    inventory_hold.save

    if inventory_hold.errors.empty?
      @inventory_hold = inventory_hold
    else
      @errors = inventory_hold.errors.to_h
      false
    end
  end
end