class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_error
  before_action :set_default_response_format, :set_locale

  def action_missing(m, *args, &block)
    head :not_found
  end

  private
  def set_default_response_format
    request.format = :json
  end

  def set_locale
    locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first if request.env['HTTP_ACCEPT_LANGUAGE']
    if locale && I18n.config.available_locales_set.include?(locale)
      I18n.locale = locale
    else
      I18n.locale = 'en'
    end
  end

  def handle_error(ex)
    logger.error "System error: #{ex.message}"
    render json: {message: I18n.t('http_status.internal_server_error')},
                  status: :internal_server_error
  end
end
