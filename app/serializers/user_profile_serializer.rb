class UserProfileSerializer < ApplicationSerializer
  identifier :id

  fields :identification, :praxis_balance

  field :effective_prestige_level, name: :level
  field :effective_prestige_expirience, name: :experience

  field :new_level_threshold do |object|
    object.new_prestige_level_threshold(object.effective_prestige_level)
  end

  field :ton_balance do |object|
    object.wallet.pretty_virtual_balance(round: true) if object.wallet
  end

  field :profile_url do |object|
    object.punk&.punk_url
  end
end
