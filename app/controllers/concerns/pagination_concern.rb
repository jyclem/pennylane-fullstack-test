# frozen_string_literal: true

# PaginationConcern allows to sets Pagination information in the Response Header
module PaginationConcern
  extend ActiveSupport::Concern

  def set_pagination_metadata(total, page, nb_by_page)
    response.headers['Pagination-Count'] = total
    response.headers['Pagination-Page'] = page
    response.headers['Pagination-Limit'] = nb_by_page
  end
end
