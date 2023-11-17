type Ingredient = {
  id: string
  name: string
}

type IngredientResponse =
| (Omit<Response, "json"> & {
    status: 200
    json: () => Ingredient[] | PromiseLike<Ingredient[]>
  })
| Response
