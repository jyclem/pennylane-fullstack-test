# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::ImportRecipes do
  subject(:import_recipes) { described_class.new('filename').call }

  let(:recipes) do
    [
      {
        title: 'Golden Sweet Cornbread',
        cook_time: 25,
        prep_time: 10,
        ingredients: [
          '1 cup all-purpose flour',
          '1 cup yellow cornmeal',
          '⅔ cup white sugar',
          '1 teaspoon salt',
          '3 ½ teaspoons baking powder',
          '1 egg',
          '1 cup milk',
          '⅓ cup vegetable oil'
        ],
        ratings: 4.74,
        cuisine: '',
        category: 'Cornbread',
        author: 'bluegirl',
        image: 'https://url/image1.jpg'
      },
      {
        title: 'Monkey Bread I',
        cook_time: 35,
        prep_time: 15,
        ingredients: [
          '3 (12 ounce) packages refrigerated biscuit dough',
          '1 cup white sugar',
          '2 teaspoons ground cinnamon',
          '½ cup margarine',
          '2 eggs',
          '1 cup packed brown sugar',
          '½ cup chopped walnuts',
          '½ cup raisins'
        ],
        ratings: 4.74,
        cuisine: '',
        category: 'Monkey Bread',
        author: 'deleteduser',
        image: 'https://url/image2.jpg'
      }
    ]
  end

  before { allow(File).to receive(:read).and_return(recipes.to_json) }

  it 'creates two recipes' do
    expect { import_recipes }.to change(Recipe, :count).by(2)
  end

  it 'creates 14 ingredients' do
    expect { import_recipes }.to change(Ingredient, :count).by(14)
  end

  it 'creates the first recipe with the right attributes' do
    import_recipes

    expect(Recipe.find_by(title: 'Golden Sweet Cornbread').attributes).to include(
      'id' => anything, 'created_at' => anything, 'updated_at' => anything, 'title' => 'Golden Sweet Cornbread',
      'cook_time' => 25, 'prep_time' => 10, 'ratings' => 4.74, 'image' => 'https://url/image1.jpg'
    )
  end

  it 'creates the second recipe with the right attributes' do
    import_recipes

    expect(Recipe.find_by(title: 'Monkey Bread I').attributes).to include(
      'id' => anything, 'created_at' => anything, 'updated_at' => anything, 'title' => 'Monkey Bread I',
      'cook_time' => 35, 'prep_time' => 15, 'ratings' => 4.74, 'image' => 'https://url/image2.jpg'
    )
  end

  it 'creates the correct ingredients' do # rubocop:disable RSpec/ExampleLength
    import_recipes

    expect(
      Ingredient.where(
        name: ['all-purpose flour', 'yellow cornmeal', 'white sugar', 'salt', 'baking powder', 'egg', 'milk',
               'vegetable oil', 'biscuit dough', 'cinnamon', 'margarine', 'brown sugar', 'walnut', 'raisin']
      ).count
    ).to be(14)
  end

  it 'creates the correct link between the first recipe and ingredients' do
    import_recipes

    expect(Recipe.find_by(title: 'Golden Sweet Cornbread').ingredients.pluck(:name)).to contain_exactly(
      'all-purpose flour', 'yellow cornmeal', 'white sugar', 'salt', 'baking powder', 'egg',
      'milk', 'vegetable oil'
    )
  end

  it 'creates the correct link between the second recipe and ingredients' do
    import_recipes

    expect(Recipe.find_by(title: 'Monkey Bread I').ingredients.pluck(:name)).to contain_exactly(
      'biscuit dough', 'brown sugar', 'cinnamon', 'egg', 'margarine', 'raisin', 'walnut', 'white sugar'
    )
  end

  it 'reads the correct file' do
    import_recipes

    expect(File).to have_received(:read).with('filename')
  end

  context 'when the json file is not found' do
    before do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      allow(Rails.logger).to receive(:error)
    end

    it 'logs and raises an error' do # rubocop:disable RSpec/MultipleExpectations
      expect { import_recipes }.to raise_error(Errno::ENOENT, 'No such file or directory')

      expect(Rails.logger).to have_received(:error).with('ERROR: File filename not found')
    end
  end

  context 'when a recipe already exists with the same name' do
    before do
      create(:recipe, title: 'Golden Sweet Cornbread')
      allow(Rails.logger).to receive(:info)
    end

    it 'does not create a recipe with the same name' do
      expect { import_recipes }.to change(Recipe, :count).by(1)
    end
  end

  context 'when ingredients already exists with the same name' do
    before { ['all-purpose flour', 'cinnamon'].each { create(:ingredient, name: _1) } }

    it 'does not create ingredients with the same name' do
      expect { import_recipes }.to change(Ingredient, :count).by(12)
    end
  end

  context 'when a recipe is missing a title' do
    before do
      recipes.first['title'] = '' # we remove the title of the first recipe to raise an error
      allow(File).to receive(:read).and_return(recipes.to_json)
      allow(Rails.logger).to receive(:info)
    end

    it 'creates the other recipes' do
      expect { import_recipes }.to change(Recipe, :count).by(1)
    end

    it 'creates the ingredients of the imported recipe only' do
      expect { import_recipes }.to change(Ingredient, :count).by(8)
    end
  end
end
