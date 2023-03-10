class Users::GenerateWeaponsImage
  include Interactor
  include AwsHelper

  delegate :user, to: :context

  SCRIPT_PATH = Rails.root.join("node_scripts/generate_weapons_image.js")

  def call
    user.with_locale do
      weapon_perks = user.equipped_weapons.each_with_object({}) do |weapon, memo|
        weapon_name = RockPaperScissorsGame::MOVE_TO_NAME[weapon.position]
        memo[weapon.position] = Rails.root.join("telegram_assets/images/#{I18n.locale}/#{weapon_name}-#{weapon.rarity}-perk.png")
      end

      weapon_images = user.equipped_weapons.reject(&:default?).each_with_object({}) do |weapon, memo|
        weapon_name = RockPaperScissorsGame::MOVE_TO_NAME[weapon.position]
        memo[weapon.position] = Rails.root.join("telegram_assets/images/weapons/#{weapon_name}-#{weapon.rarity}.png")
      end

      json = {
        locale: I18n.locale,
        weapon_perks: weapon_perks,
        weapon_images: weapon_images
      }.to_json

      data_url = `DATA='#{json}' node #{SCRIPT_PATH}`
      image = Base64.decode64(data_url.sub('data:image/png;base64,', ''));
      upload_image(folder: :weapons_image, name: "#{user.id}.png", body: image)
    end
  end
end
