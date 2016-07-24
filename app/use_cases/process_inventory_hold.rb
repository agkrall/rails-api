class ProcessInventoryHold
  def initialize(external_transaction_id, item, location, quantity, uom_code, previous_hold_code_strings, new_hold_code_strings)
    @external_transaction_id = external_transaction_id
    @item = item
    @location = location
    @quantity = quantity
    @uom_code = uom_code
    @previous_hold_code_strings = previous_hold_code_strings
    @new_hold_code_strings = new_hold_code_strings
  end

  def run
    previous_hold_codes = build_hold_code_list @previous_hold_code_strings
    new_hold_codes = build_hold_code_list @new_hold_code_strings

    if !previous_hold_codes.empty? && !new_hold_codes.empty?
      create_inventory_hold (@quantity * -1), previous_hold_codes
      create_inventory_hold @quantity, new_hold_codes
    end

    if previous_hold_codes.empty?
      create_inventory_hold @quantity, new_hold_codes
    end

    if new_hold_codes.empty?
      create_inventory_hold (@quantity * -1), previous_hold_codes
    end

    true
  end

  private
  def build_hold_code_list(hold_code_strings)
    hold_codes = []
    hold_code_strings.each do |hold_code_string|
      hold_code = HoldCode.find_by_code(hold_code_string)
      unless hold_code
        use_case = CreateHoldCode.new(hold_code_string)
        hold_code = use_case.run
      end
      hold_codes << hold_code
    end
    hold_codes
  end

  def create_inventory_hold(hold_quantity, hold_codes)
    use_case = CreateInventoryHold.new(@external_transaction_id, @item, @location, hold_quantity, @uom_code, hold_codes)
    use_case.run
  end
end