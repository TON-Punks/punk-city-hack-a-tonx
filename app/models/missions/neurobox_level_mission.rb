# == Schema Information
#
# Table name: missions
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  state      :integer          not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_missions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Missions::NeuroboxLevelMission < Mission
  after_initialize do |mission|
    mission.data["starting_level"] ||= user.effective_prestige_level
    mission.data["levels_required"] ||= Missions::NeuroboxLevel::StreakCalculator.call(user: user).level
    mission.data["levels_count"] ||= 0
  end

  def levels_count
    data["levels_count"]
  end

  def levels_required
    data["levels_required"]
  end

  def increment_levels_count!
    data["levels_count"] += 1
    save!
  end

  def levels_left
    levels_required - levels_count
  end

  def can_be_finished?
    levels_left.zero? || levels_left.negative?
  end
end
