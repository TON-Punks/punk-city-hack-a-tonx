class Api::BaseController < ActionController::API
  include Api::WebAppAuthSupport

  before_action :set_locale

  rescue_from ActiveRecord::RecordNotFound do |error|
    render json: { error: error }, status: :not_found
  end

  private

  def set_locale
    I18n.locale = current_user&.locale.presence || I18n.default_locale
  end

  def respond_with_result(result)
    if result.success?
      head :ok
    else
      render json: ErrorSerializer.render(result), status: :unprocessable_entity
    end
  end
end
