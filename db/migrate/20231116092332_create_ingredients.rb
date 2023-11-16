# frozen_string_literal: true

# We create the ingredients table which contains the names of the ingredients
class CreateIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :ingredients do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :name, null: false, index: { unique: true }

      # t.timestamps # exceptionnaly I will not add any timestamp here because I don't see the usefulness
    end
  end
end
