# frozen_string_literal: true

module Imports
  # ImportRecipes allows to import the recipes and the associated ingredients in the database from a json file
  class ImportRecipesDeprecated
    def initialize(filename)
      @filename = filename
    end

    def call
      parse_file
    end

    private

    def parse_file
      nb_recipes_imported = 0
      nb_recipes_not_imported = 0

      JSON.parse(file).each do |recipe|
        create_recipe(recipe)

        nb_recipes_imported += 1
      rescue ActiveRecord::RecordNotUnique, StandardError => e
        Rails.logger.info error_message(e, recipe)

        nb_recipes_not_imported += 1
      end

      Rails.logger.info "Import finished, #{nb_recipes_imported} imported, #{nb_recipes_not_imported} errors"
    end

    def file
      Rails.logger.info "Reading file #{@filename}..."

      File.read(@filename)
    rescue Errno::ENOENT => e
      Rails.logger.error "ERROR: File #{@filename} not found"

      raise e
    end

    def create_recipe(recipe)
      Rails.logger.info "\r\n"

      ingredients_formatted = format_ingredients(recipe)

      # first we insert all the ingredients, skipping those already existing
      Rails.logger.info "Inserting all ingredients #{ingredients_formatted}..."
      new_ingredients = insert_ingredients(ingredients_formatted)

      # then we add the new ingredients to the list of existing ingredients
      update_existing_ingredients_name_to_id(existing_ingredients_name_to_id, new_ingredients)

      # finally we create the new recipe (and raise an exception if it already exists), and then
      # we link it to the ingredients (we do it in two steps for performance reason)
      Rails.logger.info "Importing #{recipe['title']}..."
      create_recipe_and_link_with_ingredients(recipe, ingredients_formatted)
    end

    def error_message(exception, recipe = {})
      if exception.is_a?(ActiveRecord::RecordNotUnique)
        "#{recipe['title']} already exists in database... skipping recipe"
      else
        "ERROR encountered (#{exception.message})... skipping recipe"
      end
    end

    def format_ingredients(recipe)
      recipe['ingredients'].map do |ingredient|
        ingredient.gsub(/\d+[,. s]?d*/, '') # we remove all digits
                  # we remove all kitchenware
                  .gsub(/cup(s)?|teaspoon(s)?|package(s)?|tablespoon(s)?|can(s)?( or bottle)?|packed/, '')
                  # we remove food alteration
                  .gsub(/square(s)?|ground|minced|warm|chopped|water|clove(s)?|refrigerated|scalded/, '')
                  .gsub(/\(.*\)/, '') # we remove everything in parenthesis
                  .gsub(/[⅓½⅔¼¾⅛⅝]|/, '') # we remove all fractions
                  .gsub(/,.+/, '') # we remove everything after a comma
                  .singularize # we keep only "singular" ingredient to avoid duplicates
                  .strip # we remove leading and trailing whitespace
      end.compact_blank
    end

    def insert_ingredients(ingredients_formatted)
      Ingredient.insert_all(ingredients_formatted.map { { name: _1 } }, returning: %w[id name]).to_a # rubocop:disable Rails/SkipsModelValidations
    end

    def update_existing_ingredients_name_to_id(existing_ingredients_name_to_id, new_ingredients)
      new_ingredients.each do |new_ingredient|
        existing_ingredients_name_to_id[new_ingredient['name']] = new_ingredient['id']
      end
    end

    def create_recipe_and_link_with_ingredients(recipe, ingredients_formatted)
      ingredient_ids = ingredients_formatted.map { |ingredient_name| existing_ingredients_name_to_id[ingredient_name] }
      ActiveRecord::Base.transaction do # we make sure to rollback all this part if an error occurs
        new_recipe = Recipe.create!(recipe.slice('title', 'prep_time', 'cook_time', 'ratings', 'image'))
        IngredientsRecipe.insert_all( # rubocop:disable Rails/SkipsModelValidations
          ingredient_ids.map { |ingredient_id| { recipe_id: new_recipe.id, ingredient_id: } }
        )
      end
    end

    def existing_ingredients_name_to_id
      # For performance reason, we get all the existing ingredients in memory so we don't have to find
      # the ids of all the ingredients everytime we insert a new recipe
      # If it uses too much RAM, we can remove this (but the file is 5Mo for now)
      @existing_ingredients_name_to_id ||= Ingredient.all.each_with_object({}) do |ingredient, hash|
        hash[ingredient.name] = ingredient.id
      end
    end
  end
end
