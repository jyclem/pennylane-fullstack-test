# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/ingredients' do
  describe 'GET /index' do
    let!(:ingredient1) { create(:ingredient, name: 'foo bar') }
    let!(:ingredient2) { create(:ingredient, name: 'bar baz qux') }
    let!(:ingredient3) { create(:ingredient, name: 'other') }

    let(:attributes) { { name_containing: 'bar', page: 1 } }

    it 'renders a successful response' do
      get ingredients_url, params: attributes

      expect(response).to be_successful
    end

    it 'returns the expected results' do
      get ingredients_url, params: attributes

      expect(response.parsed_body).to contain_exactly(JSON.parse(ingredient1.to_json), JSON.parse(ingredient2.to_json))
    end

    it 'does not return ingredients with other ingredients' do
      get ingredients_url, params: attributes

      expect(response.parsed_body).not_to include(JSON.parse(ingredient3.to_json))
    end

    context 'when no ingredient_ids is given in parameter' do
      before { attributes.delete(:name_containing) }

      it 'renders a successful response' do
        get ingredients_url, params: attributes

        expect(response).to be_successful
      end

      it 'returns an empty array' do
        get ingredients_url, params: attributes

        expect(response.parsed_body).to eql([])
      end
    end

    context 'when no page is given in parameter' do
      before { attributes.delete(:page) }

      it 'renders a successful response' do
        get ingredients_url, params: attributes

        expect(response).to be_successful
      end

      it 'returns an empty array' do
        get ingredients_url, params: attributes

        expect(response.parsed_body).to eql([])
      end
    end
  end
end
