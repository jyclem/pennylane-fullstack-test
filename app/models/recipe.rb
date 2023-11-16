# frozen_string_literal: true

# Recipe
class Recipe < ApplicationRecord
  has_many :ingredients_recipes, inverse_of: :recipe, dependent: :delete_all
  has_many :ingredients, through: :ingredients_recipes

  validates :title, presence: true
  # I voluntarily don't create a "uniqueness" validation because it would add an extra SQL call each time validations
  # are checked. We will just handle the exception raised in case of duplicates, when inserting new data in the table

  scope :with_at_most_ingredient_ids, lambda { |ingredient_ids|
    where(id: IngredientsRecipe.recipies_containing_at_most_ingredient_ids(ingredient_ids).select(:recipe_id))
  }
end
