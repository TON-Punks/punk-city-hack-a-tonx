class Lootboxes::Deploy
  include Interactor

  delegate :lootbox, to: :context

  def call
    result = Lootboxes::ProcessPrepaid.call(lootbox: lootbox) unless lootbox.prepaid?

    if !result || result.success?
      lootbox.in_progress!
      Lootboxes::OpenWorker.perform_in(5, lootbox.id)
    else
      context.fail!(error_message: result.error_message)
    end
  end
end
