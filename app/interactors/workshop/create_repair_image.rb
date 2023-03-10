class Workshop::CreateRepairImage
  include Interactor

  SCRIPT_PATH = Rails.root.join("node_scripts/generate_repair_image.js")

  delegate :item_user, :repaired, to: :context

  def call
    context.output_path = image_path
    generate_image
  end

  private

  def image_path
    @image_path ||= Rails.root.join("tmp/repair-image-#{item_user.id}-#{repaired}.png")
  end

  def template_path
    "./telegram_assets/images/workshop/repair_#{repaired ? 'done' : 'request'}.png"
  end

  def generate_image
    json = {
      locale: I18n.locale,
      image_url: item_user.item.image_url,
      template_path: template_path,
      output_path: image_path
    }.to_json

    `DATA='#{json}' node #{SCRIPT_PATH}`
  end
end
