# frozen_string_literal: true

# RecipesController
class RecipesController < ApplicationController
  include PaginationConcern # defines set_pagination_metadata

  def index
    page = index_params[:page].to_i

    result = if index_params[:ingredient_ids] && page.positive?
               set_pagination_metadata(scope.count, index_params[:page], ApplicationRecord::DEFAULT_NB_BY_PAGE)
               scope.paginate(page)
             else
               [] # so far, if a param is missing, we don't return any information to the user
             end

    # for now we return all columns of the recipes but if needed we can use a serializer or extract specific columns
    render json: result
  end

  private

  def index_params
    params.permit(:page, ingredient_ids: [])
  end

  def scope
    @scope ||= Recipe.with_at_most_ingredient_ids(index_params[:ingredient_ids])
  end
end
