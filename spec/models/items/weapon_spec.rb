# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Items::Weapon do
  let(:weapon) { create :weapon_item, data: { stats: { min_damage: 10, max_damage: 12} } }

  specify 'data attributes' do
    expect(weapon.min_damage).to eq(10)
    expect(weapon.max_damage).to eq(12)
  end
end
