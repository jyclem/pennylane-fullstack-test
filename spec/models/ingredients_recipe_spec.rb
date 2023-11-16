# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe IngredientsRecipe do
  describe 'associations' do
    it { is_expected.to belong_to(:ingredient).inverse_of(:ingredients_recipes) }
    it { is_expected.to belong_to(:recipe).inverse_of(:ingredients_recipes) }
  end

  describe 'scopes' do
    let!(:recipe1) { create(:recipe, ingredients: [ingredient1]) }
    let!(:recipe2) { create(:recipe, ingredients: [ingredient1, ingredient2]) }
    let!(:recipe3) { create(:recipe, ingredients: [ingredient3]) }

    let(:ingredient1) { create(:ingredient) }
    let(:ingredient2) { create(:ingredient) }
    let(:ingredient3) { create(:ingredient) }

    describe 'recipes_containing_other_ingredient_ids' do
      subject do
        described_class.recipes_containing_other_ingredient_ids([ingredient3.id]).pluck(:recipe_id).uniq
      end

      it { is_expected.to contain_exactly(recipe1.id, recipe2.id) }

      it { is_expected.not_to include(recipe3.id) }
    end

    describe 'recipies_containing_at_most_ingredient_ids' do
      subject do
        described_class.recipies_containing_at_most_ingredient_ids([ingredient1.id, ingredient2.id])
                       .pluck(:recipe_id).uniq
      end

      it { is_expected.to contain_exactly(recipe1.id, recipe2.id) }

      it { is_expected.not_to include(recipe3.id) }
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
