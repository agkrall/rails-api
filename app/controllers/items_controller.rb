class ItemsController < ApplicationController
  def index
    render json: {items: Item.select(:id, :external_id).order(:external_id)}
  end

  def show
    if params[:external_id]
      item = Item.find_by_external_id(params[:id])
    else
      item = Item.find_by_id(params[:id])
    end
    if item
      render json: item.to_json(:only => [:id, :external_id])
    else
      head :not_found
    end
  end

  def update
    if item = Item.find_by_id(params[:id])
      use_case = UpdateItem.new(item, params[:external_id])
      if item = use_case.run
        render json: item.to_json(:only => [:id, :external_id])
      else
        render json: {errors: use_case.errors}, status: :bad_request
      end
    else
      head :not_found
    end
  end

  def create
    use_case = CreateItem.new(params[:external_id], params[:attributes])
    if item = use_case.run
      render json: item.to_json(:only => [:id, :external_id])
    else
      render json: {errors: use_case.errors}, status: :bad_request
    end
  end

  def search_within_location
    use_case = FindItemByUpc.new(params[:location_id], params[:upc])
    if use_case.run
      return render json: {item: use_case.item_info}
    else
      head :not_found
    end
  end
end
