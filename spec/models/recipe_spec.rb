# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipe do
  describe 'associations' do
    it { is_expected.to have_many(:ingredients_recipes).inverse_of(:recipe).dependent(:delete_all) }
    it { is_expected.to have_many(:ingredients).through(:ingredients_recipes) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'scopes' do
    describe 'with_at_most_ingredient_ids' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      subject { described_class.with_at_most_ingredient_ids([ingredient1.id, ingredient2.id]) }

      let!(:recipe1) { create(:recipe, ingredients: [ingredient1]) }
      let!(:recipe2) { create(:recipe, ingredients: [ingredient1, ingredient2]) }
      let!(:recipe3) { create(:recipe, ingredients: [ingredient1, ingredient2, ingredient3]) } # rubocop:disable RSpec/LetSetup

      let(:ingredient1) { create(:ingredient) }
      let(:ingredient2) { create(:ingredient) }
      let(:ingredient3) { create(:ingredient) }

      it { is_expected.to contain_exactly(recipe1, recipe2) }
    end
  end
end
