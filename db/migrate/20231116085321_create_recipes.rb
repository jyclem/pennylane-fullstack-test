# frozen_string_literal: true

# We create the recipes table which contains the name of the recipes and a few information about them
class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.string :title, null: false, index: { unique: true }
      t.integer :prep_time, limit: 2
      t.integer :cook_time, limit: 2
      t.decimal :ratings, precision: 3, scale: 2
      t.string :image

      t.timestamps
    end
  end
end
