# == Schema Information
#
# Table name: free_tournaments
#
#  id                    :bigint           not null, primary key
#  dynamic_prize_enabled :boolean          default(FALSE), not null
#  finish_at             :datetime         not null
#  prize_amount          :bigint           not null
#  prize_currency        :integer          not null
#  start_at              :datetime         not null
#  state                 :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class FreeTournament < ApplicationRecord
  enum state: {
    started: 0,
    finished: 1
  }

  enum prize_currency: {
    ton: 0,
    praxis: 1
  }

  has_many :user_free_tournament_statistics

  scope :ongoing, -> { where(start_at: ..Time.now.utc, finish_at: Time.now.utc..) }
  scope :waiting_finish, -> { started.where(finish_at: ..Time.now.utc) }

  class << self
    def running
      ongoing.started.first
    end

    def scheduled
      started.where(start_at: Time.now.utc..).first
    end
  end

  def statistic_for_user(user)
    user_free_tournament_statistics.where(user: user).first_or_create!
  end

  def leaderboard_photo(page = 0)
    cache_key = Time.at((Time.zone.now.to_f / 5.minutes).floor * 5.minutes).utc.to_i
    AwsConfig.free_tournament_leaderboard_url(self, page, cache_key)
  end
end
