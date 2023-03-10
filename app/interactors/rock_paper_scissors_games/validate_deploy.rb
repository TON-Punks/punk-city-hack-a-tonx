class RockPaperScissorsGames::ValidateDeploy
  include Interactor

  delegate :game, to: :context

  def call
    client = TonhubClient.new
    response = client.account(address: game.address)
    type = response['state']['type'].inquiry

    if type.active?
      game.blockchain_active!
    else
      context.fail!
    end
  end
end
