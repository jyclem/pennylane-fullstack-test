# frozen_string_literal: true

namespace :import_recipes do
  desc 'Imports the recipes from a json file into the database'
  # example: rails import_recipes:import_from_file[db/imports/recipes-en.json]
  task :import_from_file, %i[filename] => :environment do |_, args|
    Imports::ImportRecipes.new(args[:filename]).call
  end
end
