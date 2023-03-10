class AddExperienceToGames < ActiveRecord::Migration[6.1]
  class RockPaperScissorsGameStub < ApplicationRecord
    include TonHelper
    include AASM

    self.table_name = :rock_paper_scissors_games

    enum state: { created: 0, started: 1, creator_won: 2, opponent_won: 3, archived: 4 }

    TON_XP_MULTIPLIER = 20

    def pretty_bet
      from_nano(bet)
    end

    def bet_experience
      (pretty_bet.to_f * TON_XP_MULTIPLIER).ceil
    end
  end

  def change
    change_table :rock_paper_scissors_games, bulk: true do |t|
      t.integer :creator_experience
      t.integer :opponent_experience
    end

    RockPaperScissorsGameStub.where(bet: 0).where(state: 'creator_won').update_all(creator_experience: 15, opponent_experience: 0)
    RockPaperScissorsGameStub.where(bet: 0).where(state: 'opponent_won').update_all(creator_experience: 0, opponent_experience: 15)

    RockPaperScissorsGameStub.where.not(bet: 0).where(state: 'creator_won').find_each do |game|
      game.update(
        creator_experience: 100 + game.bet_experience,
        opponent_experience: 25 + game.bet_experience
      )
    end

    RockPaperScissorsGameStub.where.not(bet: 0).where(state: 'opponent_won').find_each do |game|
      game.update(
        creator_experience: 25 + game.bet_experience,
        opponent_experience: 100 + game.bet_experience
      )
    end
  end
end
