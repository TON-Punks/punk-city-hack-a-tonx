# == Schema Information
#
# Table name: black_market_products
#
#  id            :bigint           not null, primary key
#  current_price :bigint           default(0), not null
#  min_price     :bigint           default(0), not null
#  slug          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_black_market_products_on_slug  (slug) UNIQUE
#
class BlackMarketProduct < ApplicationRecord
  SLUGS = [
    WL_MUTANT_TOADZ = "wl_mutant_toadz",
    ANIMATED_PUNK = "animated_punk",
    ZEYA_MEMBERSHIP_CARD = "zeya_membership_card",
    ZEYA_NFT = "zeya_nft",
    TONARCHY_LOOTBOX = "tonarchy_lootbox",
    EMOJI_PACK = "emoji_pack",
    NEUROPUNK = "neuropunk",
    GOLDERN_FLOPPY = "golden_floppy",
    HALLOWEEN_TICKETS = "halloween_tickets",
    PUNK_LOOTBOX_INITIAL = "punk_lootbox_initial",
    AIRDROPPED_LOOTBOX = "airdropped_lootbox"
  ]

  class << self
    def fetch(slug)
      raise ActiveRecord::RecordNotFound if SLUGS.exclude?(slug.to_s)

      where(slug: slug).first_or_create!
    end
  end
end
