# frozen_string_literal: true

class CombotConfig < ApplicationConfig
  def cookie
    "auth=; uid=; session_id="
  end

  def vol1_chat_users_url
    "https://combot.org/c/-1001788180948/chat_users/v2?csv=yes&limit=3000&skip=0"
  end
end
