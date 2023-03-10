class Deeplinks::JoinGame
  def self.encode(game_id)
    Base64.urlsafe_encode64({ type: 'join_game', game_id: game_id }.to_json)
  end
end
