# == Schema Information
#
# Table name: ab_testing_experiments
#
#  id           :bigint           not null, primary key
#  participates :boolean
#  type         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_ab_testing_experiments_on_user_id           (user_id)
#  index_ab_testing_experiments_on_user_id_and_type  (user_id,type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AbTestingExperiment < ApplicationRecord
  belongs_to :user
end
