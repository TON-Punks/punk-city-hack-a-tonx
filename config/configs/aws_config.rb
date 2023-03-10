# frozen_string_literal: true

class AwsConfig < ApplicationConfig
  attr_config :access_key_id, :secret_access_key, :endpoint, :region, :image_url

  def profile_url(key, cache:)
    "#{image_url}/profiles/#{key}.png?a=#{cache}"
  end

  def weapons_url(key, cache:)
    "#{image_url}/weapons_image/#{key}.png?a=#{cache}"
  end

  def punk_url(key)
    "#{image_url}/punks/#{key}.png"
  end

  def animated_punk_url(key)
    "#{image_url}/#{animated_punk_path(key)}"
  end

  def animated_gif_punk_path(key)
    "animated_punks/#{key}.gif"
  end

  def animated_punk_path(key)
    "animated_punks_video/#{key}.mp4"
  end

  def dao_proposal_path(id)
    "dao_proposals/#{id}"
  end

  def free_tournament_leaderboard_url(tournament, page, cache_key = "", locale = nil)
    "#{image_url}/free_tournaments/#{free_tournament_leaderboard_key(tournament, page, locale)}?a=#{cache_key}"
  end

  def free_tournament_leaderboard_key(tournament, page, locale = nil)
    "#{tournament.id}_#{tournament.start_at.to_i}_#{page}_#{locale || I18n.locale}.png"
  end
end
