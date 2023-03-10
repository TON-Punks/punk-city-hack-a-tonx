require 'rails_helper'

RSpec.describe RockPaperScissorsGameDecorator do
  let(:game) { create(:rock_paper_scissors_game).decorate }

  describe 'user_modifier_descriptions' do
    let(:user) { create :user, :with_default_weapons }
    let(:expected_message) do
      "🩸 15% Шанс на критический урон\n💨 30% Шанс на уворот\n🧛 30% Шанс на вампиризм\n⚡ 10% Шанс на Контрудар\n"
    end

    before do
      game.creator = user
      game.opponent = user
      game.cache_weapons
    end

    specify do
      expect(game.user_modifier_descriptions(user)).to eq(expected_message)
    end

    context 'mythical weapons' do
      let(:user) { create :user, :with_weapons }
      let(:expected_message) do
        <<~STR
          ☢ 30% Шанс на отравление
          🔮 35% Шанс на поглощение урона
          🔄 40% Шанс на сброс всех эффектов
          ☠ 20% Шанс нанести противнику 100 урона
          🔫  30% Шанс не дать противнику использовать Электро-Катану, Лазерный Пистолет и Плазменную Гранату на следующем ходу.
        STR
      end

      specify do
        expect(game.user_modifier_descriptions(user)).to eq(expected_message)
      end
    end
  end

  describe 'end_round_message' do
    let(:user1) { create :user, :with_weapons }
    let(:user2) { create :user, :with_weapons }
    let(:total_damage) { { 'creator' => 0, 'opponent' => 0} }
    let(:game_round) { GameRound.new(rock_paper_scissors_game: game, 'creator' => 1, 'opponent' => 2) }
    let(:game_round_result) do
      GameRounds::NeoCalculateWinner.call(game_round: game_round, total_damage: total_damage, weapons: game.cached_weapons, always_proc: true)
    end

    before do
      game.opponent = user1
      game.creator = user2
      game.cache_weapons
      game_round.update(
        creator_damage: game_round_result.creator_total_damage,
        opponent_damage: game_round_result.opponent_total_damage,
        winner: game_round_result.winner
      )
    end

    specify do
      creator_text = game.creator_end_round_message_full(game_round_result)
      opponent_text = game.opponent_end_round_message_full(game_round_result)
    end
  end

  xdescribe 'health messages' do
    let(:game) { create(:rock_paper_scissors_game, :paid).decorate }

    before do
      create :game_round, rock_paper_scissors_game: game, winner: :creator, winner_damage: 8
      create :game_round, rock_paper_scissors_game: game, winner: :opponent, winner_damage: 16
    end

    specify do
      expect(game.creator_health_message).to eq("Здоровье:\nВаше: ❤️[24/40] # Враг: 👿[32/40]")
      expect(game.opponent_health_message).to eq("Здоровье:\nВаше: ❤️[32/40] # Враг: 👿[24/40]")
    end
  end

  xdescribe 'round messages' do
    let(:game) { create(:rock_paper_scissors_game, :paid).decorate }
    let(:round) { create :game_round, rock_paper_scissors_game: game, winner: :creator, winner_damage: 8, creator: 5, opponent: 1  }

    specify do
      expect(game.creator_end_round_message(round)).to include("-8💥\n\nЗдоровье:\nВаше: ❤️‍🔥[40/40] # Враг: 👿[32/40]")
      expect(game.opponent_end_round_message(round)).to include("-8💥\n\nЗдоровье:\nВаше: ❤️[32/40] # Враг: 😈[40/40]")
    end

    context 'draw' do
      let(:round) { create :game_round, rock_paper_scissors_game: game, winner: nil, winner_damage: 0 }

      specify do
        expect(game.creator_end_round_message(round)).to include("🤝 Ничья!\n\nЗдоровье:\nВаше: ❤️‍🔥[40/40] # Враг: 😈[40/40]")
        expect(game.opponent_end_round_message(round)).to include("🤝 Ничья!\n\nЗдоровье:\nВаше: ❤️‍🔥[40/40] # Враг: 😈[40/40]")
      end
    end
  end

  describe 'damage_message' do
    subject { game.damage_message(round, type: 'winner') }

    context 'miss' do
      let(:round) { create :game_round, rock_paper_scissors_game: game, winner: :creator, winner_damage: 0, winner_modifier: :miss }

      it { is_expected.to eq("💨 Промах!\n\n") }
    end

    context 'counter' do
      let(:round) { create :game_round, rock_paper_scissors_game: game, winner: :creator, winner_damage: 11, loser_modifier: :counter, loser_damage: 10 }

      it { is_expected.to eq("💀\n-11💥\n\n❤️‍🩹\n⚡ Противник контратаковал и нанес 10 урона\n\n") }
    end

    context 'heal' do
      let(:round) { create :game_round, rock_paper_scissors_game: game, winner: :creator, winner_damage: 11, loser_modifier: :heal, loser_damage: -10 }

      it { is_expected.to eq("💀\n-11💥\n\n💉 Вы восстановили +10💗 здоровья\n\n") }
    end

    context 'increased_damage' do
      let(:round) do
        create :game_round, rock_paper_scissors_game: game, winner: :creator, winner_damage: 11, winner_modifier: :increased_damage
      end

      it { is_expected.to eq("💀\n-11🔥 Вы нанесли на 30% урона больше\n\n") }
    end
  end

  describe 'health_emoji' do
    it { expect(game.health_emoji(40, 25)).to eq('❤️') }
  end

  describe 'enemy_health_emoji' do
    it { expect(game.enemy_health_emoji(40, 25)).to eq('👿') }
  end
end
