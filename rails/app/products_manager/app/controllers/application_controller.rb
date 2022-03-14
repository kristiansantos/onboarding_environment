class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from StandardError, with: :render_internal_server_error

  def render_internal_server_error(exception)
    Rails.logger.debug exception
    render json: { error: 'Something went wrong, please try again or contact our support.' },
           status: :internal_server_error
  end
end
