class Segments::Rules::FreeTournament::Participant
  class << self
    def call(user)
      new(user).call
    end
  end

  def initialize(user)
    @user = user
  end

  def call
    false
  end

  private

  attr_reader :user
end
