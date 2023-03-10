class Tournaments::UpdateBalance
  include Interactor

  delegate :tournament, to: :context

  def call
    client = TonhubClient.new
    result = client.account(address: tournament.address)
    return unless result

    new_balance = result['balance']['coins'].to_i

    tournament.update(balance: new_balance)
  end
end
