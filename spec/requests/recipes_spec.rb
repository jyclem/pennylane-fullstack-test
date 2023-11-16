# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe '/recipes' do
  describe 'GET /index' do
    let!(:recipe1) { create(:recipe, ingredients: [ingredient1]) }
    let!(:recipe2) { create(:recipe, ingredients: [ingredient1, ingredient2]) }
    let!(:recipe3) { create(:recipe, ingredients: [ingredient3]) }

    let(:ingredient1) { create(:ingredient) }
    let(:ingredient2) { create(:ingredient) }
    let(:ingredient3) { create(:ingredient) }

    let(:attributes) do
      {
        ingredient_ids: [ingredient1.id, ingredient2.id],
        page: 1
      }
    end

    it 'renders a successful response' do
      get recipes_url, params: attributes

      expect(response).to be_successful
    end

    it 'returns the expected results' do
      get recipes_url, params: attributes

      expect(response.parsed_body).to contain_exactly(JSON.parse(recipe1.to_json), JSON.parse(recipe2.to_json))
    end

    it 'does not return recipes with other ingredients' do
      get recipes_url, params: attributes

      expect(response.parsed_body).not_to include(JSON.parse(recipe3.to_json))
    end

    context 'when no ingredient_ids is given in parameter' do
      before { attributes.delete(:ingredient_ids) }

      it 'renders a successful response' do
        get recipes_url, params: attributes

        expect(response).to be_successful
      end

      it 'returns an empty array' do
        get recipes_url, params: attributes

        expect(response.parsed_body).to eql([])
      end
    end

    context 'when no page is given in parameter' do
      before { attributes.delete(:page) }

      it 'renders a successful response' do
        get recipes_url, params: attributes

        expect(response).to be_successful
      end

      it 'returns an empty array' do
        get recipes_url, params: attributes

        expect(response.parsed_body).to eql([])
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
