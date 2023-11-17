# frozen_string_literal: true

# IngredientsController
class IngredientsController < ApplicationController
  include PaginationConcern # defines set_pagination_metadata

  def index
    page = index_params[:page].to_i

    result = if index_params[:name_containing] && page.positive?
               set_pagination_metadata(scope.count, index_params[:page], 50)
               scope.paginate(page, 50)
             else
               [] # so far, if a param is missing, we don't return any information to the user
             end

    render json: result
  end

  private

  def index_params
    params.permit(:page, :name_containing)
  end

  def scope
    @scope ||= Ingredient.with_name_containing(index_params[:name_containing])
  end
end
