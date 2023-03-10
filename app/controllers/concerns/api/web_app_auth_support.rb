# frozen_string_literal: true

module Api::WebAppAuthSupport
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  attr_reader :current_user

  def authenticate_user!
    result = Api::InitDataProcessor.call(init_data: request_init_data)

    if result.success?
      @current_user = result.user
    elsif (user = User.find_by_auth_token!(params[:token]))
      @current_user = user
    else
      head :unauthorized
    end
  end

  def request_init_data
    request.headers["Authorization"]&.gsub(/^Bearer /, "")
  end
end
