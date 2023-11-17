import React, { useState } from 'react'
import IngredientsSearch from './Ingredients/Search'
import RecipesContainer from './Recipes/Container'

const Home = () => {
  const [selectedIngredients, setSelectedIngredients] = useState<Ingredient[]>(
    []
  )

  return (
    <div className="home container">
      <div className="row">
        <div className="col-xs-4">
          <IngredientsSearch setSelectedIngredients={setSelectedIngredients} />
        </div>
      </div>
      <div className="row mt-5">
        <div className="col-xs-4">
          <RecipesContainer selectedIngredients={selectedIngredients} />
        </div>
      </div>
    </div>
  )
}

export default Home
