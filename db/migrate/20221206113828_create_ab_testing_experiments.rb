class CreateAbTestingExperiments < ActiveRecord::Migration[6.1]
  def change
    create_table :ab_testing_experiments do |t|
      t.string :type, null: false
      t.references :user, null: false, foreign_key: true
      t.boolean :participates

      t.timestamps
    end

    add_index :ab_testing_experiments, %i[user_id type], unique: true
  end
end
