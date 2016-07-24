class FindItemByUpc
  attr_reader :item_info

  def initialize(location_id, upc)
    @location_id = location_id
    @upc = upc
  end

  def run
    location = Location.find_by_id(@location_id)
    return false unless location

    item = Item.find_by_upc(@upc)
    return false unless item

    soh_use_case = RetrieveStockOnHand.new(item, location)
    return false unless soh_use_case.run

    item_info = item.as_json
    item_info['upc'] = @upc
    item_info['image_url'] = 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Banana.png/489px-Banana.png'
    item_info['in_stock'] = soh_use_case.stock_on_hand
    item_info['about'] = 'This product is AWESOME. So is Steve.'
    @item_info = item_info
  end
end