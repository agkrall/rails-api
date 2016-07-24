class ReasonCodesController < ApplicationController
  def index
    render json: {reason_codes: ReasonCode.all.order(:code)}
  end

  def show
    reason_code = ReasonCode.find_by_code(params[:code])

    if reason_code
      render json: reason_code
    else
      head :not_found
    end
  end

  def update
    if reason_code = ReasonCode.find_by_code(params[:code])
      use_case = UpdateReasonCode.new(reason_code, params[:description], params[:impacts_soh])
      if reason_code = use_case.run
        render json: reason_code
      else
        render json: { errors: use_case.errors }, status: :bad_request
      end
    else
      head :not_found
    end
  end

  def create
    use_case = CreateReasonCode.new(params[:code], params[:description], params[:impacts_soh])
    if reason_code = use_case.run
      render json: reason_code
    else
      render json: {errors: use_case.errors}, status: :bad_request
    end
  end
end
