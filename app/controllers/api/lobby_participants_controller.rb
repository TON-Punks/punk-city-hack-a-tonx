class Api::LobbyParticipantsController < Api::BaseController
  def index
    render json: UserProfileSerializer.render(User.first(5), root: :lobby_participants)
  end

  def create
    head :ok
  end

  def destroy
    head :no_content
  end
end
