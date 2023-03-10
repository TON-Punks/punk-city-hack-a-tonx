class GameRounds::NeoCalculateWinner
  include Interactor
  include RedisHelper

  delegate :game_round, :total_damage, :always_proc, :weapons, :winner_id, :loser_id, to: :context
  delegate :rock_paper_scissors_game, to: :game_round
  delegate :opponent_id, :creator_id, to: :rock_paper_scissors_game

  ATTACK_PERKS = %w[poison critical contusion counter breaker blinding_light onearmed_bandit]
  DEFENCE_PERKS = %w[faraday miss force_field paracelsus vampirism system_reset]

  EFFECTS_KEY = 'EFFECTS-KEY'
  KEY_TTL = 60.minutes.to_i

  def call
    setup_context
    calculate_winner
    calculate_winner_damage
    tick_effects
    apply_perks

    serialize_effects
    finalize_round
  end

  private

  def setup_context
    context.damages = { creator_id => 0, opponent_id => 0 }
    context.events = { creator_id => [], opponent_id  => []}
    context.effects = parse_effects || { creator_id => {}, opponent_id => {} }
    context.effects_damage = { creator_id => {}, opponent_id => {}}
  end

  def tick_effects
    [rock_paper_scissors_game.opponent, rock_paper_scissors_game.creator].each do |user|
      context.effects[user.id].each do |effect, effects_data|
        tick_effect(user, effect, effects_data)
      end
    end
  end

  def tick_effect(user, effect, effects_data)
    rounds, *extra_data = effects_data
    if rounds > 0
      new_rounds = rounds - 1
      context.effects[user.id][effect] = extra_data.present? ? extra_data.unshift(new_rounds) : new_rounds
      effect_method = "#{effect}_effect"
      send(effect_method, user, context.effects[user.id][effect]) if respond_to?(effect_method, true)
    else
      effect_data = context.effects[user.id].delete(effect)
      if respond_to?(:"#{effect}_effect_end", true)
        send(:"#{effect}_effect_end", user, effect_data)
      else
        context.events[user.id] << :"#{effect}_end"
      end
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
      context.winner_id = opponent_id
      context.loser_id = creator_id
    else
      context.winning_move = game_round.creator
      context.losing_move =  game_round.opponent
      context.winner = 'creator'
      context.loser = 'opponent'
      context.winner_id = creator_id
      context.loser_id = opponent_id
    end
  end

  def calculate_winner_damage
     return unless context.winner

      winner_weapon = weapons[rock_paper_scissors_game.public_send(context.winner).id][game_round.public_send(context.winner)]
      context.damages[winner_id] += weapon_damage(winner_weapon)
  end

  def apply_perks
    apply_weapon_perks(weapons[opponent_id][game_round.opponent], rock_paper_scissors_game.opponent, context.winner == 'opponent', ATTACK_PERKS)
    apply_weapon_perks(weapons[opponent_id][game_round.opponent], rock_paper_scissors_game.opponent, context.winner == 'opponent', DEFENCE_PERKS)

    apply_weapon_perks(weapons[creator_id][game_round.creator], rock_paper_scissors_game.creator, context.winner == 'creator', ATTACK_PERKS)
    apply_weapon_perks(weapons[creator_id][game_round.creator], rock_paper_scissors_game.creator, context.winner == 'creator', DEFENCE_PERKS)
  end

  def apply_weapon_perks(item, item_owner, winner, perks)
    return if item.perks.blank?

    perks.each do |perk|
      next unless item.perks.keys.include?(perk)

      send("#{perk}_perk", winner, item_owner, item)
    end
  end

  def weapon_damage(item)
    rand(item.min_damage..item.max_damage)
  end

  def finalize_round
    context.both_moved = true

    # Okay this one needs to be changes but in `damages` the key is `by` whom damage was made. in effects_damage the key is the `target`
    #
    context.creator_total_damage = context.damages[creator_id].to_i + context.effects_damage[opponent_id].to_h.values.map { |value| Array(value).first }.sum
    context.opponent_total_damage = context.damages[opponent_id].to_i + context.effects_damage[creator_id].to_h.values.map { |value| Array(value).first }.sum
  end

  ### New

  def parse_effects
    effects = redis.get(effects_redis_key)
    JSON.parse(effects).transform_keys(&:to_i) if effects
  end

  def serialize_effects
    json = context.effects.to_json
    redis.setex(effects_redis_key, KEY_TTL, json)
  end

  def poison_effect(user, rounds_left)
    context.effects_damage[user.id]['poison'] = [max_damage_to(user, rand(4..6)), rounds_left]
  end

  def paracelsus_effect(user, rounds_left)
    heal = max_heal(user, 8)
    context.effects_damage[user.id]['paracelsus'] = [-heal, rounds_left]
  end

  def contusion_effect(user, rounds_left)
    return if loser_id == user.id

    move = rock_paper_scissors_game.creator == user ? game_round.opponent : game_round.creator
    weapon_user = rock_paper_scissors_game.creator == user ? rock_paper_scissors_game.opponent : rock_paper_scissors_game.creator
    weapon = weapons[weapon_user.id][move]
    context.damages[weapon_user.id] += weapon_damage(weapon) / 2
  end

  def force_field_effect(user, effect_data)
    rounds_left, _ = effect_data
    context.effects_damage[user.id]['force_field'] = [0, rounds_left]
    _, previous_damage = context.effects[user.id]['force_field']

    if winner_id == user.id || winner_id.blank?
      context.effects[user.id]['force_field'] = [rounds_left, previous_damage]
    else
      context.effects[user.id]['force_field'] = [rounds_left, previous_damage + context.damages[winner_id]]
      context.damages[winner_id] = 0
    end
  end

  def force_field_effect_end(user, effect_data)
    context.effects_damage[user.id]['force_field_end'] = effect_data.last
  end

  def counter_perk(winner, item_owner, item)
    if !winner && context.loser.present? && proc?(item.perks['counter'])
      context.events[item_owner.id] << :counter
      counter_damage = weapon_damage(item)

      context.damages[loser_id] += max_damage_from(item_owner, counter_damage)
    end
  end

  def breaker_perk(winner, item_owner, item)
    if winner && proc?(item.perks['breaker'])
      context.damages[winner_id] = 100
    end
  end

  def contusion_perk(_, item_owner, item)
    if proc?(item.perks['contusion'])
      context.effects[not_item_owner(item_owner).id]['contusion'] = 1
      context.events[not_item_owner(item_owner).id] << :contusion
    end
  end

  def critical_perk(winner, item_owner, item)
    if winner && proc?(item.perks['critical'])
      context.events[item_owner.id] << :critical
      context.damages[winner_id] *= 2
    end
  end

  def poison_perk(_, item_owner, item)
    chance, rounds = item.perks['poison']

    if proc?(chance)
      user = not_item_owner(item_owner)
      context.effects[user.id]['poison'] = rounds - 1
      poison_effect(user, rounds - 1)
    end
  end

  def faraday_perk(winner, item_owner, item)
    if !winner && winner_damage > 0 && proc?(item.perks['faraday'])
      context.events[item_owner.id] << :faraday
      context.damages[winner_id] = (context.damages[winner_id] * 0.2).to_i
    end
  end

  def miss_perk(winner, item_owner, item)
    if !winner && winner_damage > 0 && proc?(item.perks['miss'])
      context.events[item_owner.id] << :miss
      context.damages[winner_id] = 0
    end
  end

  def force_field_perk(_, item_owner, item)
    chance, rounds = item.perks['force_field']
    if proc?(chance)
      context.effects[item_owner.id]['force_field'] = [rounds - 1, 0]
      force_field_effect(item_owner, [rounds - 1, 0])
    end
  end

  def paracelsus_perk(_, item_owner, item)
    chance, rounds = item.perks['paracelsus']

    if proc?(chance)
      context.effects[item_owner.id]['paracelsus'] = rounds - 1
      paracelsus_effect(item_owner, rounds - 1)
    end
  end

  def blinding_light_perk(_, item_owner, item)
    if proc?(item.perks['blinding_light'])
      context.events[not_item_owner(item_owner).id] << :blinding_light
      context.effects[not_item_owner(item_owner).id]['blinding_light'] = 0
    end
  end

  def onearmed_bandit_perk(_, item_owner, item)
    if proc?(item.perks['onearmed_bandit'])
      context.events[not_item_owner(item_owner).id] << :onearmed_bandit
      context.effects[not_item_owner(item_owner).id]['onearmed_bandit'] = 0
    end
  end

  def vampirism_perk(winner, item_owner, item)
    if winner && context.loser.present? && proc?(item.perks['vampirism'])
      context.effects_damage[item_owner.id]['vampirism'] = -max_heal(item_owner, winner_damage)
    end
  end

  def system_reset_perk(winner, item_owner, item)
    if proc?(item.perks['system_reset'])
      context.events[item_owner.id] << :system_reset
      context.effects[item_owner.id] = {}
    end
  end

  ###

  def max_damage_to(user, damage)
    key = rock_paper_scissors_game.opponent_id == user.id ? 'opponent' : 'creator'
    user_health = rock_paper_scissors_game.send("#{key}_health")
    max_possible_damage = [user_health - total_damage[flip_type(key)] - 1, 0].max
    [max_possible_damage, damage].min
  end

  def max_damage_from(user, damage)
    key = rock_paper_scissors_game.opponent_id == user.id ? 'opponent' : 'creator'
    not_user_health = rock_paper_scissors_game.send("#{flip_type(key)}_health")
    max_possible_damage = [not_user_health - total_damage[key] - 1, 0].max
    [max_possible_damage, damage].min
  end

  def flip_type(type)
    type == 'creator' ? 'opponent' : 'creator'
  end

  def max_heal(user, heal)
    key = rock_paper_scissors_game.opponent_id == user.id ? 'creator' : 'opponent'
    [total_damage[key], heal].min
  end

  def effects_redis_key
    "#{EFFECTS_KEY}-#{rock_paper_scissors_game.id}"
  end

  def not_item_owner(owner)
    [rock_paper_scissors_game.opponent, rock_paper_scissors_game.creator].detect { _1 != owner }
  end

  def proc?(chance)
    chance.to_f >= rand || always_proc
  end

  def winner_damage
    context.damages[winner_id].to_i
  end
end
