export const fetchRecipes = ({ page, ingredientIds }: { page: number, ingredientIds: string[] }): Promise<RecipeResponse> => {
  return fetch(`/recipes?page=${page}&ingredient_ids[]=${ingredientIds.join('&ingredient_ids[]=')}`)
}
