class ChangeNullForUserHalloweenStatistics < ActiveRecord::Migration[6.1]
  def change
    change_column_default :user_halloween_statistics, :total_damage, 0
    change_column_null :user_halloween_statistics, :total_damage, false
  end
end
