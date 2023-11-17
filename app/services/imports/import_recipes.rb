# frozen_string_literal: true

module Imports
  # ImportRecipes allows to import the recipes and the associated ingredients in the database from a json file
  class ImportRecipes
    attr_accessor :ingredients_to_insert, :inserted_ingredients,
                  :recipes_to_insert, :inserted_recipes,
                  :recipes_to_ingredients, :total_recipes

    def initialize(filename)
      @filename = filename

      @ingredients_to_insert = []
      @inserted_ingredients = []

      @recipes_to_insert = []
      @inserted_recipes = []

      @recipes_to_ingredients = {}
      @total_recipes = 0
    end

    def call
      parse_file

      insert_data

      Rails.logger.info "Import finished, #{inserted_recipes.count} imported, " \
                        "#{total_recipes - inserted_recipes.count} errors"
    end

    private

    def parse_file
      JSON.parse(file).each do |recipe|
        @total_recipes += 1

        process_recipe(recipe)
      rescue StandardError => e
        Rails.logger.info "ERROR: #{e}... skipping #{recipe['title']}"
      end
    end

    def process_recipe(recipe)
      return if recipe['title'].blank?

      recipes_to_insert << recipe.slice('title', 'prep_time', 'cook_time', 'ratings', 'image')

      ingredients_formatted = format_ingredients(recipe)

      ingredients_to_insert.concat(ingredients_formatted.map { { name: _1 } })

      recipes_to_ingredients[recipe['title']] = ingredients_formatted
    end

    def insert_data
      ActiveRecord::Base.transaction do
        # rubocop:disable Rails/SkipsModelValidations
        @inserted_ingredients = Ingredient.insert_all(ingredients_to_insert, returning: %w[id name])
        @inserted_recipes = Recipe.insert_all(recipes_to_insert, returning: %w[id title])
        IngredientsRecipe.insert_all(ingredients_recipes_to_insert)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    def file
      Rails.logger.info "Reading file #{@filename}..."

      File.read(@filename)
    rescue Errno::ENOENT => e
      Rails.logger.error "ERROR: File #{@filename} not found"

      raise e
    end

    def format_ingredients(recipe) # rubocop:disable Metrics/MethodLength
      recipe['ingredients'].map do |ingredient|
        ingredient.downcase
                  .gsub(/\d+[,. ]?d*/, '') # we remove all digits (including those separated by . and ,)
                  .gsub(/[\*®]/, '') # we remove all special characters
                  .gsub(/[⅓½⅔¼¾⅛⅜⅝⅞]|/, '') # we remove all fractions
                  # we remove all kitchenware
                  .gsub(/cup(s)?|teaspoon(s)?|package(s)?|tablespoon(s)?|can(s)?( or bottle)?|packed|ounce(s)?/, '')
                  # we remove food alteration
                  .gsub(/square(s)?|ground|minced|warm|chopped|water|clove(s)?|refrigerated|scalded/, '')
                  .gsub(/\(.*\)/, '') # we remove everything in parenthesis
                  .gsub(/,.+/, '') # we remove everything after a comma
                  .gsub(/^\. ?/, '') # we remove a leading "." or ". "
                  .singularize.strip # we keep "singular" ingredient and remove leading and trailing whitespace
      end.compact_blank
    end

    def ingredients_recipes_to_insert
      recipes_to_ingredients.each_with_object([]) do |(recipe_title, ingredient_names), array|
        ingredient_names.each do |ingredient_name|
          recipe_id = recipes_title_to_id[recipe_title]
          ingredient_id = ingredients_name_to_id[ingredient_name]

          array << { recipe_id:, ingredient_id: } if recipe_id && ingredient_id
        end
      end
    end

    def ingredients_name_to_id
      @ingredients_name_to_id ||= inserted_ingredients.each_with_object({}) do |ingredient, hash|
        hash[ingredient['name']] = ingredient['id']
      end
    end

    def recipes_title_to_id
      @recipes_title_to_id ||= inserted_recipes.each_with_object({}) do |recipe, hash|
        hash[recipe['title']] = recipe['id']
      end
    end
  end
end
