# frozen_string_literal: true

# IngredientsRecipe
class IngredientsRecipe < ApplicationRecord
  belongs_to :ingredient, inverse_of: :ingredients_recipes
  belongs_to :recipe, inverse_of: :ingredients_recipes

  scope :recipes_containing_other_ingredient_ids, ->(ingredient_ids) { where.not(ingredient_id: ingredient_ids) }

  scope :recipies_containing_at_most_ingredient_ids, lambda { |ingredient_ids|
    where(ingredient_id: ingredient_ids).where.not(
      recipe_id: recipes_containing_other_ingredient_ids(ingredient_ids).select(:recipe_id)
    )
  }
end
