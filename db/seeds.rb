# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

first_item = Items::Weapon.create!(name: "katana_1", data: { type: "katana", damage: 10 })
second_item = Items::Weapon.create!(name: "katana_2", data: { type: "katana", damage: 30 })

ItemsUser.create!(item: first_item, user: User.first, data: { equipped: false })
ItemsUser.create!(item: second_item, user: User.first, data: { equipped: false })
