class Missions::NeuroboxLevel::ResetHandler
  include Interactor

  delegate :user, to: :context

  def call
    user.neurobox_level_missions.running.update_all(state: :failed)
  end
end
