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
class Segments::FreeTournament < Segment
  AVAILABLE_NAMES = [
    PARTICIPANT = "participant".freeze
  ].freeze

  class << self
    def available_names
      AVAILABLE_NAMES
    end
  end
end
