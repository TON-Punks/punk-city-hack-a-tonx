class RockPaperScissorsGames::CreateResultsImage
  include Interactor

  delegate :game, :creator_output_path, :opponent_output_path, to: :context
  delegate :opponent, :creator, to: :game

  SCRIPT_PATH = Rails.root.join("node_scripts/generate_results_image.js")

  def call
    unless game.creator.bot?
      context.creator_output_path = generate_results_image_path(game.id, creator.id)
      creator.with_locale { generate_results_image(creator_output_path, creator.locale || I18n.locale, true) }
    end

    if game.boss.blank? && !game.opponent.bot?
      context.opponent_output_path = generate_results_image_path(game.id, opponent.id)
      opponent.with_locale { generate_results_image(opponent_output_path, opponent.locale || I18n.locale, false) }
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

  def generate_results_image_path(game_id, user_id)
    Rails.root.join("tmp/results-image-#{game_id}-for-#{user_id}.png")
  end

  def generate_results_image(output_path, locale, for_creator)
    creator_level = I18n.t("generated_images.profile.level", level: creator.punk&.prestige_level || creator.prestige_level)
    level = game.boss ? RockPaperScissorsGames::Halloween.level : (opponent.punk&.prestige_level || opponent.prestige_level)
    opponent_level = I18n.t("generated_images.profile.level", level: level)

    creator_id = creator.identification.downcase
    opponent_id = game.boss ? "" : opponent.identification.downcase

    env_vars = <<~ENV_VARS
      LOCALE="#{locale}"
      OUTPUT_PATH="#{output_path}"
      USER_IMAGE="#{for_creator ? creator_image : opponent_image}"
      OPPONENT_IMAGE="#{for_creator ? opponent_image : creator_image}"
      USER_LVL="#{for_creator ? creator_level : opponent_level}"
      OPPONENT_LVL="#{for_creator ? opponent_level : creator_level}"
      USER_NAME="#{for_creator ? creator_id : opponent_id}"
      OPPONENT_NAME="#{for_creator ? opponent_id : creator_id}"
      USER_WIN_COUNT="#{for_creator ? creator_win_count : opponent_win_count}"
      OPPONENT_WIN_COUNT="#{for_creator ? opponent_win_count : creator_win_count}"
      USER_WON="#{for_creator ? game.creator_won? : game.opponent_won?}"
    ENV_VARS

    node_output = `#{env_vars.squish} node #{SCRIPT_PATH}`
  end

  def creator_win_count
    @creator_win_count ||= game_rounds_stats["creator"].to_i
  end

  def opponent_win_count
    @opponent_win_count ||= game_rounds_stats["opponent"].to_i
  end

  def game_rounds_stats
    @game_rounds_stats ||= game.game_rounds.group(:winner).count
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
    elsif opponent.punk
      "#{punk_folder}/#{opponent.punk.number}.png"
    end
  end
end
