# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::Weapons::Equip do
  context 'when equippin weapon instead of default one' do
    let(:user) { create :user, :with_default_weapons }
    let(:weapon) { Item.build_from_data(:weapon, Lootboxes::SERIES_TO_CONTENT[:initial].first[:data]) }
    let(:weapon_user) { user.items_users.create(item: weapon) }

    it 'unequippes in the same position' do
      expect(Users::UpdateWeaponsImageWorker).to receive(:perform_async).with(user.id)
      described_class.call(user: user, weapon_user_id: weapon_user.id)

      expect(weapon_user.reload.data['equipped']).to eq(true)
      expect(user.equipped_weapons.count).to eq(5)
    end
  end
end
