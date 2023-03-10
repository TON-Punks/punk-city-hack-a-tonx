class RockPaperScissorsGames::ValidateCompleteness
  include Interactor
  include TonHelper

  ONE_MOVE_THRESHOLD = 200_000_000 # it should be 300_000_000, but I've decreased it "just in case"
  TRANSACTION_DELTA = 10_000_000
  delegate :game, to: :context

  def call
    response = tonhub_client.account(address: game.address)
    type = response['state']['type'].inquiry

    raise "Game wasn't deployed" if !game.blockchain_active? && !type.active?
    balance = response['balance']['coins'].to_i

    if balance.zero?
      game.blockchain_complete!
    elsif balance < ONE_MOVE_THRESHOLD
      game.blockchain_incomplete!
    else
      resend_missing_move
    end
  end

  private

  def resend_missing_move
    sent_moves = transactions.each_with_object(Hash.new(0)) do |transaction, memo|
      memo[transaction['in_msg']['source']] += transaction['in_msg']['value'].to_i
      out_msg = transaction['out_msgs'].first

      memo[out_msg['destination']] -= out_msg['value'].to_i if out_msg
    end

    user_type = %w[opponent creator].detect do |user_type|
      user = game.public_send(user_type)
      sent_moves[user.wallet.base64_address_bounce] < TRANSACTION_DELTA
    end

    raise "Moves are sent but contract still has money " if user_type.blank?
    RockPaperScissorsGames::SendMove.call(game: game, user_type: user_type)
  end

  def transactions
    @transactions ||= toncenter_client.account_transactions(address: game.address)
  end

  def tonhub_client
    @tonhub_client ||= TonhubClient.new
  end

  def toncenter_client
    @toncenter_client ||= ToncenterClient.new
  end
end
