export const fetchIngredients = ({ name }: { name: string }): Promise<IngredientResponse> => {
  return fetch(`/ingredients?page=1&name_containing=${name}`) // for ingredients we will always get the first page only
}
