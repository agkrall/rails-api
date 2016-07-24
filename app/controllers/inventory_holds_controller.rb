class InventoryHoldsController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      holds = params[:holds]
      holds.each do |hold|
        item = Item.find_by_id(hold[:item_id])
        location = Location.find_by_id(hold[:location_id])
        use_case = ProcessInventoryHold.new(hold[:external_transaction_id], item, location, hold[:quantity].to_f, hold[:uom_code],
                                            hold[:previous_hold_codes], hold[:new_hold_codes])
        unless use_case.run
          return head :bad_request
        end
      end
    end

    render json: {}
  end
end