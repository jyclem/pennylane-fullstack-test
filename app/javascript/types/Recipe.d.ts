type Recipe = {
  id: string
  title: string
  prep_time: number
  cook_time: number
  ratings: number
  image: string
}

type RecipeResponse =
| (Omit<Response, "json"> & {
    status: 200
    json: () => Recipe[] | PromiseLike<Recipe[]>
  })
| Response
