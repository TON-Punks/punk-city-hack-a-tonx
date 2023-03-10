class PunkBlueprint < Blueprinter::Base
  field  :avatar_url do |punk|
    punk.punk_url
  end

  field :name  do |punk|
    "TON PUNK ##{punk.number}"
  end
end
