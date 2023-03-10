class RockPaperScissorsGames::CreateWeaponsImage
  include Interactor

  delegate :game, :game_round, to: :context
  delegate :opponent, :creator, to: :game

  SCRIPT_PATH = Rails.root.join("node_scripts/generate_weapons_result_image.js")

  def call
    unless game.creator.bot?
      context.creator_output_path = generate_results_image_path(creator.id)
      generate_from_creator_perspective
    end

    unless game.opponent.bot?
      context.opponent_output_path = generate_results_image_path(opponent.id)
      generate_from_opponent_perspective
    end
  end

  private

  def generate_results_image_path(user_id)
    Rails.root.join("tmp/weapons-image-#{context.game_round.id}-for-#{user_id}.png")
  end

  def generate_from_creator_perspective
    env_vars = <<~ENV_VARS
      FIRST_PERSON_IMAGE_PATH=#{creator_image_path}
      SECOND_PERSON_IMAGE_PATH=#{opponent_image_path}
      MOVE_1=#{creator_weapon}
      MOVE_2=#{opponent_weapon}
      OUTPUT_PATH=#{context.creator_output_path}
      LOCALE=#{creator.locale || I18n.locale}
    ENV_VARS

    `#{env_vars.squish} node #{SCRIPT_PATH}`
  end

  def generate_from_opponent_perspective
    env_vars = <<~ENV_VARS
      FIRST_PERSON_IMAGE_PATH=#{opponent_image_path}
      SECOND_PERSON_IMAGE_PATH=#{creator_image_path}
      MOVE_1=#{opponent_weapon}
      MOVE_2=#{creator_weapon}
      OUTPUT_PATH=#{context.opponent_output_path}
      LOCALE=#{opponent.locale || I18n.locale}
    ENV_VARS

    `#{env_vars.squish} node #{SCRIPT_PATH}`
  end

  def opponent_image_path
    weapon = game.cached_weapons.to_h.dig(opponent.id, game_round.opponent)
    return if weapon.blank? || weapon.default?

    "./telegram_assets/images/weapons/#{opponent_weapon}-#{weapon.rarity}.png"
  end

  def default_opponent_image_path
    "#{opponent_weapon}_#{creator_weapon}.png"
  end

  def creator_image_path
    weapon = game.cached_weapons.to_h.dig(creator.id, game_round.creator)
    return if weapon.blank? || weapon.default?

    "./telegram_assets/images/weapons/#{creator_weapon}-#{weapon.rarity}.png"
  end

  def default_creator_image_path
    "#{creator_weapon}_#{opponent_weapon}.png"
  end

  def opponent_weapon
    RockPaperScissorsGame::MOVE_TO_NAME[game_round.opponent]
  end

  def creator_weapon
    RockPaperScissorsGame::MOVE_TO_NAME[game_round.creator]
  end
end
