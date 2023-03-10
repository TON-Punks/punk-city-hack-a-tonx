class RepExperience::CombotFetcher
  include Interactor

  def call
    context.raw_data = StringIO.new(client.get(config.vol1_chat_users_url)).read
  end

  private

  def client
    @client ||= HTTP.headers("cookie" => config.cookie)
  end

  def config
    @config ||= CombotConfig
  end
end
