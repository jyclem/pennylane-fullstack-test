# frozen_string_literal: true

require 'rake'

# ImportRecipesEnV1
class ImportRecipesEnV1 < ActiveRecord::Migration[7.1]
  def up
    Imports::ImportRecipes.new('db/imports/recipes-en_v1.json').call
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
