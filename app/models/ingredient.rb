# frozen_string_literal: true

# Ingredient
class Ingredient < ApplicationRecord
  has_many :ingredients_recipes, inverse_of: :ingredient, dependent: :delete_all
  has_many :recipes, through: :ingredients_recipes

  validates :name, presence: true
  # I voluntarily don't create a "uniqueness" validation because it would add an extra SQL call each time validations
  # are checked. We will just handle the exception raised in case of duplicates, when inserting new data in the table

  scope :with_name_containing, ->(string) { where('name LIKE ?', "%#{string}%") }
end
