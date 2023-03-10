# == Schema Information
#
# Table name: segments
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_segments_on_name_and_type  (name,type) UNIQUE
#
class Segment < ApplicationRecord
  UNKNOWN_SEGMENT_NAME_ERROR = Class.new(StandardError)

  has_many :segments_users
  has_many :users, through: :segments_users

  class << self
    def fetch(name)
      raise UNKNOWN_SEGMENT_NAME_ERROR if available_names.exclude?(name.to_s)

      where(name: name.to_s, type: self.name).first_or_create!
    end
  end
end
