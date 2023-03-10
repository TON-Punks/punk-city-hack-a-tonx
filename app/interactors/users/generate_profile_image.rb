class Users::GenerateProfileImage
  include Interactor
  include AwsHelper

  delegate :user, to: :context

  SCRIPT_PATH = Rails.root.join("node_scripts/generate_profile.js")

  def call
    user.with_locale do
      stats = user.rock_paper_scissors_statistic
      actor = user.punk || user

      json = {
        locale: I18n.locale,
        level: I18n.t("generated_images.profile.level", level: actor.prestige_level),
        games_count: stats.games_won + stats.games_lost,
        wins: stats.games_won,
        wins_label: I18n.t("generated_images.profile.wins"),
        loses: stats.games_lost,
        loses_label: I18n.t("generated_images.profile.loses"),
        ton_won: stats.pretty_ton_won,
        ton_lost: stats.pretty_ton_lost,
        punk_url: user.punk&.punk_url,
        identification: user.identification.downcase
      }.to_json

      data_url = `DATA='#{json}' node #{SCRIPT_PATH}`
      image = Base64.decode64(data_url.sub('data:image/png;base64,', ''));
      upload_image(folder: :profiles, name: "#{user.id}.png", body: image)
    end
  end
end
