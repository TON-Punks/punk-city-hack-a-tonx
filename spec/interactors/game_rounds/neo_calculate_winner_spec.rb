# frozen_string_literal: true

require 'rails_helper'

RSpec.xdescribe GameRounds::NeoCalculateWinner do
  let(:creator) { create :user }
  let(:opponent) { create :user }
  let(:game) { create :rock_paper_scissors_game, :started, creator: creator, opponent: opponent }

  def generate_game_round(creator_name, opponent_name)
    GameRound.new(
      rock_paper_scissors_game: game,
      'creator' => RockPaperScissorsGame::NAME_TO_MOVE[creator_name],
      'opponent' => RockPaperScissorsGame::NAME_TO_MOVE[opponent_name]
    )
  end

  def generate_weapons(rarity)
    Lootboxes::SERIES_TO_CONTENT[:initial].
      select { |weapon| weapon[:data][:rarity] == rarity }.
      map { |item| Item.build_from_data(:weapon, item[:data])}.
      index_by { |item| item.data['position'] }
  end

  subject(:result) do
    described_class.call(game_round: game_round, total_damage: game.total_damage, always_proc: true, weapons: weapons)
  end

  context 'mythical weapons' do
    let(:weapons) do
      { opponent.id => generate_weapons(:rare), creator.id => generate_weapons(:rare) }
    end

    context 'when system_reset and force_field' do
      let(:game_round) { generate_game_round(:hack, :katana) }

      specify do
        expect(result.effects_damage.values.map { _1.keys }.flatten).to match_array(%i[force_field])
        expect(result.events.values.flatten).to match_array(%i[system_reset])
      end
    end

    context 'when breaker and onearmed_bandit' do
      let(:game_round) { generate_game_round(:pistol, :grenade) }

      specify do
        expect(result.damages[opponent.id]).to eq(100)
        expect(result.events.values.flatten).to match_array(%i[onearmed_bandit breaker])
      end
    end

    context 'when poison' do
      let(:game_round) { generate_game_round(:annihilation, :grenade) }

      specify do
        expect(result.effects_damage.values.map { _1.keys }.flatten).to match_array(%i[poison])
      end
    end
  end

  context 'rare weapons' do
    let(:weapons) do
      { opponent.id => generate_weapons(:rare), creator.id => generate_weapons(:rare) }
    end

    context 'when system_reset and force_field' do
      let(:game_round) { generate_game_round(:hack, :katana) }

      specify do
        expect(result.effects_damage.values.map { _1.keys }.flatten).to match_array(%i[force_field])
        expect(result.events.values.flatten).to match_array(%i[system_reset])
      end
    end

    context 'when breaker and onearmed_bandit' do
      let(:game_round) { generate_game_round(:pistol, :grenade) }

      specify do
        expect(result.events.values.flatten).to match_array(%i[onearmed_bandit breaker])
      end
    end

    context 'when critical' do
      let(:game_round) { generate_game_round(:annihilation, :katana) }

      specify do
        expect(result.events.values.flatten).to match_array(%i[faraday])
      end
    end
  end
end
