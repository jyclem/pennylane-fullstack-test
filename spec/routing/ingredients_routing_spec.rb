# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngredientsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/ingredients').to route_to('ingredients#index')
    end
  end
end
