# frozen_string_literal: true

FactoryBot.define do
  factory :recipe do
    title { Faker::Food.unique.dish }
    prep_time { Faker::Number.number(digits: 2) }
    cook_time { Faker::Number.number(digits: 2) }
    ratings { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    image { Faker::Internet.url }
  end
end
