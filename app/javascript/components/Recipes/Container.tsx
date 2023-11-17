import React, { useState, useEffect } from 'react'
import { fetchRecipes } from '../../api/recipes'
import List from './List'
import Pagination from '../shared/Pagination'

const Container = ({
  selectedIngredients,
}: {
  selectedIngredients: Ingredient[]
}) => {
  const [recipesList, setRecipesList] = useState<Recipe[]>([])
  const [pagination, setPagination] = useState<Pagination | object>({})

  const fetchRecipesList = async (page: number) => {
    const ingredientIds = selectedIngredients.map(
      (ingredient: Ingredient) => ingredient.id
    )
    const response = await fetchRecipes({ page, ingredientIds })

    if (response.status === 200) {
      setPagination({
        count: parseInt(response.headers.get('Pagination-Count') || '0'),
        page: parseInt(response.headers.get('Pagination-Page') || '0'),
        limit: parseInt(response.headers.get('Pagination-limit') || '0'),
      })

      const recipes: Recipe[] = await response.json()
      setRecipesList(recipes)
    } else {
      setRecipesList([])
    }
  }

  useEffect(() => {
    if (selectedIngredients.length === 0) return

    fetchRecipesList(1)
  }, [selectedIngredients])

  return (
    <div className="container">
      <div className="row">
        <div className="col-xs-4">
          {recipesList.length > 0 ? (
            <List recipesList={recipesList} />
          ) : (
            <div>No recipe</div>
          )}
          {'page' in pagination && (
            <Pagination {...pagination} fetch={fetchRecipesList} />
          )}
        </div>
      </div>
    </div>
  )
}

export default Container
