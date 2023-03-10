class RockPaperScissorsGames::SendMoves
  include Interactor
  include RedisHelper

  SEND_SCRIPT_PATH = Rails.root.join("node_scripts/send_moves.js")

  delegate :game, :dry_run, to: :context

  def call
    return if game.address.blank?

    creator = game.creator
    opponent = game.opponent
    return if creator.blank? || opponent.blank?

    %w[opponent creator].each do |user_type|
      RockPaperScissorsGames::SendMove.call(game: game, dry_run: dry_run, user_type: user_type)
    end

    RockPaperScissorsGames::ValidateCompletenessWorker.perform_in(60 * 2, game.id)
  end
end
