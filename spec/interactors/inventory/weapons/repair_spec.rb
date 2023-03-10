# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::Weapons::Repair do
  let(:user) { create :user, :with_default_weapons }
  let(:weapon) { Item.build_from_data(:weapon, Lootboxes::SERIES_TO_CONTENT[:initial].first[:data]) }
  let(:item_user) { user.items_users.create(item: weapon, data: { equipped: true, current_durability: weapon.durability - 5, restored_durability: 5 }) }

  specify do
    user.praxis_transactions.regular_exchange.create!(quantity: 3000)
    # expect(Users::UpdateWeaponsImageWorker).to receive(:perform_async).with(user.id)
    described_class.call(user: user, weapon_user_id: item_user.id)

    expect(item_user.reload.data['current_durability']).to eq(weapon.durability)
    expect(item_user.reload.data['restored_durability']).to eq(10)
    expect(user.praxis_balance).to eq(2695)
  end
end
