class Admin::BaseController < ActionController::Base
  layout 'admin'

  before_action :authenticate!

  def authenticate!
    authenticate_or_request_with_http_basic do |login, password|
      login == AdminConfig.login && password == AdminConfig.password
    end
  end
end
