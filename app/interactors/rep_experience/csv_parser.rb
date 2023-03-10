class RepExperience::CsvParser
  include Interactor

  delegate :raw_data, to: :context

  def call
    context.data = CSV.parse(raw_data).map do |user_data|
      {
        chat_id: user_data.first,
        name: user_data.second,
        rep: user_data.last.to_i
      }
    end
  end
end
