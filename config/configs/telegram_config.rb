# frozen_string_literal: true

class TelegramConfig < ApplicationConfig
  attr_config :bot_credentials, :bot_username, :bot_url, :bot_ids, :ru_cyber_arena_chat_id,
    :en_cyber_arena_chat_id, :sapiens_chat_id, :holder_vol1_ru

  def deeplink(data)
    "#{TelegramConfig.bot_url}?start=#{data}"
  end
end
