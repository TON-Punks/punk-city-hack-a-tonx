# == Schema Information
#
# Table name: items
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  name       :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_items_on_name  (name) UNIQUE
#
class Items::Praxis < Item
  def collectable?
    true
  end
end
