class GameRounds::CalculateWinner
  include Interactor

  DAMAGE_MODIFIERS = {
    hack: 1,
    grenade: 1.25,
    annihilation: 2
  }

  PROC_CHANCES = {
    katana: 0.3,
    pistol: 0.1,
    hack: 0.3,
    annihilation: 0.15
  }

  delegate :game_round, :total_damage, :always_proc, :winning_move, :losing_move, :winner_damage, to: :context

  def call
    calculate_winner
    context.winner_damage = context.winner ? random_damage : 0
    return if !context.winner

    apply_winner_modifier
    apply_loser_modifier
  end

  private

  def random_damage
    case rand(0..10)
    when 0..1
      11
    when 1..8
      rand(12..14)
    when 8..10
      15
    end
  end

  def calculate_winner
    return if game_round.opponent == game_round.creator

    opponent_won = (game_round.opponent % 5 + 1 == game_round.creator) || \
      (game_round.opponent % 5 + 3 == game_round.creator) || \
      (game_round.creator % 5 + 2 == game_round.opponent)

    if opponent_won
      context.winning_move = game_round.opponent
      context.losing_move = game_round.creator
      context.winner = 'opponent'
      context.loser = 'creator'
    else
      context.winning_move = game_round.creator
      context.losing_move =  game_round.opponent
      context.winner = 'creator'
      context.loser = 'opponent'
    end
  end

  def apply_winner_modifier
    name = RockPaperScissorsGame::MOVE_TO_NAME[winning_move]
    send("#{name}_modifier", true)
  end

  def apply_loser_modifier
    name = RockPaperScissorsGame::MOVE_TO_NAME[losing_move]
    send("#{name}_modifier", false)
  end

  def annihilation_modifier(winner)
    if winner && proc?(:annihilation)
      context.winner_modifier = :critical
      context.winner_damage *= DAMAGE_MODIFIERS[:annihilation]
    end
  end

  def hack_modifier(winner)
    if winner && proc?(:hack)
      context.loser_modifier = :heal
      heal = context.winner_damage * DAMAGE_MODIFIERS[:hack]
      loser_damage = [total_damage[context.loser], heal].min

      context.loser_damage = -loser_damage
    end
  end

  def katana_modifier(winner)
    if !winner && proc?(:katana)
      context.winner_modifier = :miss
      context.winner_damage = 0
    end
  end

  def grenade_modifier(winner)
    return unless winner

    context.winner_modifier = :increased_damage
    context.winner_damage *= DAMAGE_MODIFIERS[:grenade]
  end

  def pistol_modifier(winner)
    if !winner && proc?(:pistol)
      context.loser_modifier = :counter
      counter_damage = random_damage
      max_damage = [User::BASE_HP - total_damage[context.loser] - 1, 0].max
      damage = [max_damage, counter_damage].min

      context.loser_damage = damage
    end
  end

  def proc?(type)
    PROC_CHANCES[type] >= rand || always_proc
  end
end
