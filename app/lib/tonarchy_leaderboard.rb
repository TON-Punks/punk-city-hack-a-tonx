class TonarchyLeaderboard
  include HTTParty

  attr_reader :with_punk

  def initialize(with_punk)
    @with_punk = with_punk
  end

  def call
    tonarchy_users.each.with_index(0).map do |attributes, index|
      emoji = position_emoji(index)
      user = users[attributes['chatId'].to_s]

      "#{emoji} `#{attributes['username']}` -- #{attributes['influence']}"
    end.join("\n")
  end

  def users
    @users ||= begin
      chat_ids = tonarchy_users.map { |attributes| attributes['chatId'] }
      User.where(chat_id: chat_ids).index_by(&:chat_id)
    end
  end

  def position_emoji(pos)
    case pos
    when 0 then '🥇'
    when 1 then '🥈'
    when 2 then '🥉'
    when 3...limit then '🏅'
    else
      '🎗'
    end
  end

  def tonarchy_users
    @tonarchy_users ||= begin
      response = self.class.get("https://api.tonarchy.online/getLeaderboard?limit=#{limit}&whitelist=false&punks=#{with_punk}")
      response.parsed_response['result']
    end
  end

  def limit
    with_punk ? 10 : 5
  end
end
