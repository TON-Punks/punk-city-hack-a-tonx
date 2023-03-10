class Segments::Recalculator
  class << self
    def call(segments)
      new(segments).call
    end
  end

  def initialize(segments)
    @segments = segments
  end

  def call
    User.find_each do |user|
      process_user(user) if not_bot?(user)
    end
  end

  private

  attr_reader :segments

  def not_bot?(user)
    user.chat_id.to_i.positive?
  end

  def process_user(user)
    prepared_segments.each do |segment|
      matching_segment_name = Segments::Rules::Fetcher.call(user, segment)
      next if matching_segment_name == user.segment_for(segment)&.name

      ApplicationRecord.transaction do
        user.segments_users.joins(:segment).where(segments: { type: segment.name }).destroy_all
        user.segments << segment.fetch(matching_segment_name) if matching_segment_name.present?
      end
    end
  end

  def prepared_segments
    @prepared_segments ||= Array.wrap(segments).map do |segment|
      segment.is_a?(String) ? segment.constantize : segment
    end
  end
end
