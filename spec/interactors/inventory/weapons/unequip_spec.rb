# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::Weapons::Unequip do
  context 'when unequipping weapon it sets default weapon' do
    let(:user) { create :user, :with_default_weapons }
    let(:weapon) { Item.build_from_data(:weapon, Lootboxes::SERIES_TO_CONTENT[:initial].first[:data]) }
    let(:weapon_user) { user.items_users.create(item: weapon).tap { _1.equip! } }

    before do
      user.items_users.joins(:item).merge(Items::Weapon.with_rarity(:default)).each(&:unequip!)
    end

    it 'unequippes in the same position' do
      expect(Users::UpdateWeaponsImageWorker).to receive(:perform_async).with(user.id)
      described_class.call(user: user, weapon_user_id: weapon_user.id)

      expect(weapon_user.reload.data['equipped']).to eq(false)
      default_weapon = user.equipped_weapons.first
      expect(default_weapon.rarity).to eq('default')
    end
  end
end
