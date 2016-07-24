class LocationsController < ApplicationController
  def index
    render json: { locations: Location.select(:id, :external_id).order(:external_id) }
  end

  def show
    if params[:external_id]
      location = Location.find_by_external_id(params[:id])
    else
      location = Location.find_by_id(params[:id])
    end
    if location
      render json: location.to_json(:only => [:id, :external_id])
    else
      head :not_found
    end
  end

  def update
    if location = Location.find_by_id(params[:id])
      use_case = UpdateLocation.new(location, params[:external_id])
      if location = use_case.run
        render json: location.to_json(:only => [:id, :external_id])
      else
        render json: { errors: use_case.errors }, status: :bad_request
      end
    else
      head :not_found
    end
  end

  def create
    use_case = CreateLocation.new(params[:external_id])
    if location = use_case.run
      render json: location.to_json(:only => [:id, :external_id])
    else
      render json: { errors: use_case.errors }, status: :bad_request
    end
  end
end
