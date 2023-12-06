# frozen_string_literal: true

# in Ingredients, we add a GIN Trigram index on name for search speed improvements
class AddGinTrigramIndexOnNameInIngredients < ActiveRecord::Migration[7.1]
  def up
    add_index :ingredients, :name, opclass: :gin_trgm_ops, using: :gin, name: :index_ingredients_on_name_gin_trgm
  end

  def down
    remove_index :ingredients, name: :index_ingredients_on_name_gin_trgm
  end
end
