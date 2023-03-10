class TonConnectController < ApplicationController
  def show
    ton_connect = TonConnect.new(user)
    Users::CheckTonConnectionWorker.perform_in(10, user.id)

    redirect_to ton_connect.url
  end

  def user
    @user ||= User.find_by_auth_token!(params[:token])
  end
end
