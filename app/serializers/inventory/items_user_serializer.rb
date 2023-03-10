class Inventory::ItemsUserSerializer < ApplicationSerializer
  identifier :id

  fields :data

  association :item, blueprint: Inventory::ItemSerializer
end
