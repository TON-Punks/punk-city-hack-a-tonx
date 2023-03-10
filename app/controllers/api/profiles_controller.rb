class Api::ProfilesController < Api::BaseController
  def show
    render json: UserProfileSerializer.render(current_user, root: :profile)
  end
end
