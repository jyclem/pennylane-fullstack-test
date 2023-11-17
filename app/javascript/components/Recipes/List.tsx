import React from 'react'

const List = ({ recipesList }: { recipesList: Recipe[] }) => (
  <table className="recipes-list table">
    <thead>
      <tr>
        <th>Title</th>
        <th>Preparation time</th>
        <th>Cooking time</th>
        <th>Ratings</th>
        <th>Image</th>
      </tr>
    </thead>
    <tbody>
      {recipesList.map((recipe: Recipe) => {
        return (
          <tr key={recipe.id}>
            <td>{recipe.title}</td>
            <td>{recipe.prep_time}</td>
            <td>{recipe.cook_time}</td>
            <td>{recipe.ratings}</td>
            <td>{recipe.image && <img src={recipe.image} alt="" />}</td>
          </tr>
        )
      })}
    </tbody>
  </table>
)

export default List
