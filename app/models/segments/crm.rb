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
class Segments::Crm < Segment
  AVAILABLE_NAMES = [
    BEGINNER = "beginner".freeze,
    REGULAR_FREE = "regular_free".freeze,
    REGULAR_PAYER = "regular_payer".freeze,
    CHAMPION_FREE = "champion_free".freeze,
    CHAMPION_PAYER = "champion_payer".freeze,
    INACTIVE = "inactive".freeze
  ].freeze

  class << self
    def available_names
      AVAILABLE_NAMES
    end
  end
end
