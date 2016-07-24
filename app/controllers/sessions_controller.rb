class SessionsController < ApplicationController
  def create
    use_case = CreateSession.new(params[:username], params[:password])
    if use_case.run
      render json: { id_token: use_case.id_token }
    else
      render json: { message: 'Invalid login' }, status: :unauthorized
    end
  end
end
