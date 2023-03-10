class FreeTournaments::Leaderboard::Generate
  include Interactor
  include AwsHelper

  SCRIPT_PATH = Rails.root.join("node_scripts/generate_free_tournament_leaderboard.js")

  def call
    return if tournament.blank?

    page = 0

    loop do
      result = FreeTournaments::Leaderboard::StatisticsData.call(tournament: tournament, page: page)

      I18n.available_locales.each do |locale|
        generate_and_upload_leaderboard(locale, result.leaderboard, page)
      end
      break if result.last_page

      page += 1
    end
  end

  private

  def generate_and_upload_leaderboard(locale, users_data, page)
    json = {
      locale: locale,
      date: "#{start_date}-#{end_date}",
      users_data: users_data
    }.to_json

    data_url = `DATA='#{json}' node #{SCRIPT_PATH}`
    image = Base64.decode64(data_url.sub("data:image/png;base64,", ""))

    upload_image(
      folder: :free_tournaments, name: AwsConfig.free_tournament_leaderboard_key(tournament, page, locale), body: image
    )
  end

  def start_date
    pretty_date(tournament.start_at)
  end

  def end_date
    pretty_date(tournament.finish_at)
  end

  def pretty_date(date)
    date.strftime("%d.%m")
  end

  def tournament
    @tournament ||= context.tournament.presence || FreeTournament.running
  end
end
