# frozen_string_literal: true

# This table makes the link between the recipes and the ingredients
class CreateIngredientsRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :ingredients_recipes, id: false do |t|
      t.belongs_to :ingredient # belongs_to will create the appropriate index
      t.belongs_to :recipe # belongs_to will create the appropriate index
    end

    add_index :ingredients_recipes, %i[ingredient_id recipe_id], unique: true
  end
end
