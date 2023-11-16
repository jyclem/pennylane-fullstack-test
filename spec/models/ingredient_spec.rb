# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ingredient do
  describe 'associations' do
    it { is_expected.to have_many(:ingredients_recipes).inverse_of(:ingredient).dependent(:delete_all) }
    it { is_expected.to have_many(:recipes).through(:ingredients_recipes) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'scopes' do
    describe 'with_name_containing' do
      subject { described_class.with_name_containing('bar') }

      let!(:ingredient1) { create(:ingredient, name: 'foo bar') }
      let!(:ingredient2) { create(:ingredient, name: 'bar baz qux') }
      let!(:ingredient3) { create(:ingredient, name: 'other') } # rubocop:disable RSpec/LetSetup

      it { is_expected.to contain_exactly(ingredient1, ingredient2) }
    end
  end
end
