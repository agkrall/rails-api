class InventoryController < ApplicationController
  def index
    items = params[:item_id] ? [Item.find(params[:item_id])] : Item.all
    locations = params[:location_id] ? [Location.find(params[:location_id])] : Location.all
    inventory = []
    items.each do |item|
      locations.each do |location|
        inventory << retrieve_soh(item, location)
      end
    end
    render json: {inventory: inventory}
  end

  def create_transaction
    ActiveRecord::Base.transaction do
      transactions = params[:transactions]
      transactions.each do |transaction|
        external_transaction_id = transaction[:external_transaction_id]
        transaction[:lines].each do |line|
          use_case = get_transaction_use_case(params[:transaction_code], external_transaction_id, line)
          unless use_case.run
            return render json: {errors: use_case.errors}, status: :bad_request
          end
        end
      end
    end

    render json: {}
  end

  private
  def retrieve_soh(item, location)
    use_case = RetrieveStockOnHand.new(item, location)
    use_case.run
    {
        item_id: item.id,
        external_item_id: item.external_id,
        location_id: location.id,
        external_location_id: location.external_id,
        stock_on_hand: use_case.stock_on_hand
    }
  end

  def get_transaction_use_case(transaction_code, external_transaction_id, line_hash)
    item = Item.find(line_hash[:item_id])
    location = Location.find(line_hash[:location_id])
    quantity = line_hash[:quantity].to_f
    uom_code = line_hash[:uom_code]
    if transaction_code == 'InventoryAdjustment'
      CreateInventoryTransaction.new(external_transaction_id,
                                     item,
                                     location,
                                     quantity,
                                     uom_code)
    elsif transaction_code == 'InventoryCount'
      CreateInventoryCount.new(item,
                               location,
                               quantity,
                               external_transaction_id,
                               uom_code)
    end
  end
end
