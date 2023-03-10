class RockPaperScissorsGames::CreateVersusImage
  include Interactor

  SCRIPT_PATH = Rails.root.join("node_scripts/generate_versus_image.js")

  delegate :game, :creator_output_path, :opponent_output_path, to: :context
  delegate :opponent, :creator, to: :game

  def call
    unless game.creator.bot?
      context.creator_output_path = generate_versus_image_path(game.id, creator.id)
      creator.with_locale { generate_versus_image(creator_output_path, true) }
    end

    if game.boss.blank? && !game.opponent.bot?
      context.opponent_output_path = generate_versus_image_path(game.id, opponent.id)
      opponent.with_locale { generate_versus_image(opponent_output_path, false) }
    end
  end

  def punk_folder
    if Rails.env.production?
      "/home/deploy/apps/punk_multiverse/shared/public/punks"
    else
      Rails.root.join("spec/fixtures/punks/")
    end
  end

  private
  def generate_versus_image_path(game_id, user_id)
    Rails.root.join("tmp/versus-image-#{game.id}-for-#{user_id}.png")
  end

  def generate_versus_image(output_path, for_creator)
    creator_level = I18n.t("generated_images.profile.level", level: creator.punk&.prestige_level || creator.prestige_level)
    level = game.boss ? RockPaperScissorsGames::Halloween.level : (opponent.punk&.prestige_level || opponent.prestige_level)
    opponent_level = I18n.t("generated_images.profile.level", level: level)

    creator_id = creator.identification.downcase
    opponent_id = game.boss ? "" : opponent.identification.downcase

    env_vars = <<~ENV_VARS
      LOCALE="#{I18n.locale}"
      OUTPUT_PATH="#{output_path}"
      CREATOR_IMAGE="#{for_creator ? creator_image : opponent_image}"
      OPPONENT_IMAGE="#{for_creator ? opponent_image : creator_image}"
      CREATOR_LVL="#{for_creator ? creator_level : opponent_level}"
      OPPONENT_LVL="#{for_creator ? opponent_level : creator_level}"
      CREATOR_NAME="#{for_creator ? creator_id : opponent_id}"
      OPPONENT_NAME="#{for_creator ? opponent_id : creator_id}"
    ENV_VARS

    node_output = `#{env_vars.squish} node #{SCRIPT_PATH}`
  end

  def creator_image
    "#{punk_folder}/#{creator.punk.number}.png" if creator.punk
  end

  def boss_image
    boss_level = RockPaperScissorsGames::Halloween.level

    Rails.root.join("telegram_assets/images/#{game.boss}_boss/boss_#{boss_level}.png")
  end

  def opponent_image
    if game.boss.present?
      boss_image
    elsif opponent&.punk
      "#{punk_folder}/#{opponent.punk.number}.png"
    end
  end
end
