# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workshop::CreateRepairImage do
  let(:user) { create :user, :with_default_weapons }
  let(:weapon) { Item.build_from_data(:weapon, Lootboxes::SERIES_TO_CONTENT[:initial].first[:data]) }
  let(:weapon_user) { user.items_users.create(item: weapon) }
  let(:repaired) { true }

  after do
    File.delete("tmp/repair-image-#{weapon_user.id}-#{repaired}.png")
  end

  specify do
    described_class.call(item_user: weapon_user, repaired: repaired)
    expect(File).to exist(Rails.root.join("tmp/repair-image-#{weapon_user.id}-#{repaired}.png"))
  end
end
