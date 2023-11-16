# frozen_string_literal: true

FactoryBot.define do
  factory :ingredient do
    name { Faker::Food.unique.ingredient }
  end
end
