class RockPaperScissorsGameDecorator < ApplicationDecorator
  delegate_all

  MODIFIERS_WITH_TEXT = %w[heal counter miss]

  def user_modifier_descriptions(user)
    return I18n.t('fight.modifier_descriptions') unless free?

    cached_weapons[user.id].values.flatten.each_with_object('') do |weapon, message|
      next unless weapon.perks

      weapon.perks.each do |perk, extra_options|
        chance, _ = Array(extra_options)
        perk_message = I18n.t!("fight.weapons.perk_descriptions.#{perk}", chance: (chance * 100).to_i) rescue next
        message << "#{perk_message}\n"
      end
    end
  end

  def creator_end_round_message_full(game_round_result)
    message = game_round_result.winner.present? ? "" : "🤝\n"

    message += "❤️‍🩹\n" if game_round_result.events[creator.id].present? || game_round_result.effects_damage[creator.id].present? || game_round_result.damages[creator.id].nonzero?
    message += "💥 -#{game_round_result.damages[creator.id]}\n" if  game_round_result.damages[creator.id].nonzero?
    message += effects_damage_message(game_round_result, creator.id, :affected)
    message += events_message(game_round_result, creator.id, :affected)

    message += "\n"

    message += "💀\n" if game_round_result.events[opponent.id].present? || game_round_result.effects_damage[opponent.id].present? || game_round_result.damages[opponent.id].nonzero?
    message += "💥 -#{game_round_result.damages[opponent.id]}\n" if  game_round_result.damages[opponent.id].nonzero?
    message += effects_damage_message(game_round_result, opponent.id, :other)
    message += events_message(game_round_result, opponent.id, :other)

    message += creator_health_message
  end

  def opponent_end_round_message_full(game_round_result)
    message = game_round_result.winner.present? ? "" : "🤝\n"

    message += "❤️‍🩹\n" if game_round_result.events[opponent.id].present? || game_round_result.effects_damage[opponent.id].present? || game_round_result.damages[opponent.id].nonzero?
    message += "💥 -#{game_round_result.damages[opponent.id]}\n" if  game_round_result.damages[opponent.id].nonzero?
    message += effects_damage_message(game_round_result, opponent.id, :affected)
    message += events_message(game_round_result, opponent.id, :affected)
    damage = game_round_result.winner_id == opponent.id ? game_round_result.winner_damage : game_round_result.loser_damage

    message += "\n"

    message += "💀\n" if game_round_result.events[creator.id].present? || game_round_result.effects_damage[creator.id].present? || game_round_result.damages[creator.id].nonzero?
    message += "💥 -#{game_round_result.damages[creator.id]}\n" if  game_round_result.damages[creator.id].nonzero?
    message += effects_damage_message(game_round_result, creator.id, :other)
    message += events_message(game_round_result, creator.id, :other)

    message += opponent_health_message
  end

  def creator_end_round_message(round)
    damage_message_type = case round.winner
      when 'creator' then 'winner'
      when 'opponent' then 'loser'
      when nil then 'draw'
    end

    message = damage_message(round, type: damage_message_type)

    message += creator_health_message
  end

  def opponent_end_round_message(round)
    damage_message_type = case round.winner
      when 'creator' then 'loser'
      when 'opponent' then 'winner'
      when nil then 'draw'
    end

    message = damage_message(round, type: damage_message_type)

    message += opponent_health_message
  end

  def effects_damage_message(game_round_result, user_id, relation_key)
    game_round_result.effects_damage[user_id].each_with_object('') do |(effect_key, extra_data), memo|
      amount, rounds_left = Array(extra_data)
      text =  I18n.t!("rock_paper_scissors_games.effect_damages.#{relation_key}.#{effect_key}", amount: amount * -1, rounds_left: rounds_left) rescue next
      memo << "#{text}\n"
    end
  end

  def events_message(game_round_result, user_id, relation_key)
    game_round_result.events[user_id].each_with_object('') do |effect_key, memo|
      text =  I18n.t!("rock_paper_scissors_games.events.#{relation_key}.#{effect_key}") rescue next
      memo << "#{text}\n"
    end
  end

  def damage_message(round, type:)
    message = ''
    message += I18n.t('rock_paper_scissors_games.draw') if !round.winner
    if round.winner_damage.to_i.nonzero?
      message += "#{damage_receiver_emoji(type)}\n"
      message += (-round.winner_damage).to_s
      message += damage_modifier_message(round, type)
      message += "\n\n"
    end

    if round.loser_damage.to_i.nonzero?
      message += "#{damage_receiver_emoji(flip_type(type))}\n" if round.loser_damage > 0
      message += damage_modifier_message(round, flip_type(type), true)
      message += "\n\n"
    end
    if round.winner_modifier == 'miss'
      message += I18n.t('rock_paper_scissors_games.miss')
    end
    message
  end

  def creator_health_message
    I18n.t('rock_paper_scissors_games.health_message',
      emoji: health_emoji(creator_health, creator_current_health),
      health: creator_current_health,
      total_health: creator_health,
      enemy_emoji:  enemy_health_emoji(opponent_health, opponent_current_health),
      enemy_health: opponent_current_health,
      enemy_total_health: opponent_health
    )
  end

  def opponent_health_message
    I18n.t('rock_paper_scissors_games.health_message',
      emoji: health_emoji(opponent_health, opponent_current_health),
      health: opponent_current_health,
      total_health: opponent_health,
      enemy_emoji: enemy_health_emoji(opponent_health, creator_current_health),
      enemy_health: creator_current_health,
      enemy_total_health: creator_health
    )
  end

  def damage_modifier_message(round, type, flipped_type = false)
    modifier = round.public_send("#{type}_modifier")

    flipped_modifier = round.public_send("#{flip_type(type)}_modifier")
    modifier = flipped_modifier if flipped_modifier == 'increased_damage'

    type = flip_type(type) if modifier == 'counter' && !flipped_type
    type = flip_type(type) if modifier == 'heal' && flipped_type
    return '💥' if modifier.blank? || (type == 'winner' && round.loser_modifier == 'miss')

    %Q(#{modifier_emoji(modifier)} #{I18n.t("rock_paper_scissors_games.damage_modifier.#{type}.#{modifier}", amount: round.loser_damage.to_i.abs)})
  end

  def health_emoji(total_health, health)
    case health.to_f / total_health * 100
      when 90..100 then '❤️‍🔥'
      when 50...90 then '❤️'
      when 10...50 then '❤️‍🩹'
      when 0...10 then '💔'
    end
  end

  def enemy_health_emoji(total_health, health)
    case health.to_f / total_health * 100
      when 90..100 then '😈'
      when 50...90 then '👿'
      when 10...50 then '😡'
      when 0...10 then '☠️'
    end
  end

  def modifier_emoji(modifier)
    if boss
      case modifier
        when 'increased_damage' then '🧛'
        when 'critical' then '🎃'
        when 'heal' then '✝️'
        when 'miss' then '🍭'
        when 'counter' then '🔫'
      end
    else
      case modifier
        when 'increased_damage' then '🔥'
        when 'critical' then '🩸'
        when 'heal' then '💉'
        when 'miss' then '💨'
        when 'counter' then '⚡'
      end
    end
  end

  def damage_receiver_emoji(type)
    case type
    when 'winner' then '💀'
    when 'loser' then '❤️‍🩹'
    end
  end

  def flip_type(type)
    type == 'winner' ? 'loser' : 'winner'
  end

  def creator_current_health
    @creator_current_health ||= [creator_health - total_damage['opponent'], 0].max
  end


  def opponent_current_health
    @opponent_current_health ||= [opponent_health - total_damage['creator'], 0].max
  end
end
