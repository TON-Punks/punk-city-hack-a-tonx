class RockPaperScissorsGames::ValidateCreatorBalance
  include Interactor

  delegate :game, to: :context

  def call
    return if game.can_pay?(game.creator)

    game.archive!
  end
end
