# frozen_string_literal: true

# ApplicationRecord
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  DEFAULT_NB_BY_PAGE = 20

  # we could use a gem instead of this scope but I prefer to avoid using too many gems for maintenance reasons
  scope :paginate, lambda { |page, number_per_page = DEFAULT_NB_BY_PAGE|
    offset((page - 1) * number_per_page).limit(number_per_page)
  }
end
