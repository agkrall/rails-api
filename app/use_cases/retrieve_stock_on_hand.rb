class RetrieveStockOnHand
  attr_reader :stock_on_hand

  def initialize(item, location)
    @item_id = item.id
    @location_id = location.id
  end

  def run
    @stock_on_hand = calculate_stock_on_hand
    true
  end

  private
  def calculate_stock_on_hand
    latest_stock_count_adjustment = InventoryAdjustment.where(item_id: @item_id, location_id: @location_id, transaction_code: 'InventoryCount').order('created_at').last
    if latest_stock_count_adjustment.nil?
      InventoryAdjustment.where('item_id = ? AND location_id = ?', @item_id, @location_id).sum(:quantity)
    else
      latest_stock_count = InventoryCount.find_by(inventory_adjustment: latest_stock_count_adjustment)
      latest_stock_count.quantity + InventoryAdjustment.where('item_id = ? AND location_id = ? AND created_at > ?',
                                                              @item_id, @location_id,
                                                              latest_stock_count.created_at).sum(:quantity)
    end
  end
end