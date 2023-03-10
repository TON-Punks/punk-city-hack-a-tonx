class Segments::RecalculationWorker
  include Sidekiq::Job

  SCHEDULED_SEGMENTS = [Segments::Crm].freeze

  sidekiq_options queue: "low", retry: 1

  def perform(segments = [])
    Segments::Recalculator.call(segments.presence || SCHEDULED_SEGMENTS)
  end
end
