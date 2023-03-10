period = Rails.env.test? ? 10 : 2
cache_store = ActiveSupport::Cache::MemoryStore.new
Rack::Attack.cache.store = cache_store

# Rack::Attack.throttle("general requests", limit: 5, period: period) do |request|
#   if request.path == '/telegram'
#     params = JSON.parse(request.body.read)
#     # We only care about callback queries and actual messages
#     params.dig('message', 'from', 'id') || params.dig('callback_query', 'from', 'id')
#     request.body.rewind
#   end
# end

Rack::Attack.throttled_responder = lambda do |request|
  [202, {}, [""]]
end
