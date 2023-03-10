class Punks::UpdateOwners
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform
    request = HTTP.get("https://tonapi.io/v1/nft/getItemsByCollectionAddress", params: {
      account: "EQAo92DYMokxghKcq-CkCGSk_MgXY5Fo1SPW20gkvZl75iCN"
    })

    nft_items = request.parse('application/json')['nft_items']
    punks = Punk.all.index_by(&:address)

    nft_items.each do |item|
      punk = punks[item['address']]
      owner_address = item['owner']['address']
      if punk.owner != owner_address
        punk.update(owner: owner_address)

        Punks::ValidateConnectionWorker.perform_async(punk.id) if punk.user

        punk.punk_connections.requested.each do |punk_connection|
          Users::CheckPunkConnectionWorker.perform_async(punk_connection.user_id)
        end
      end
    end
  end
end
