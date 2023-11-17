import React, { useState } from 'react'
import AsyncSelect from 'react-select/async'
import { fetchIngredients } from '../../api/ingredients'
import type { MultiValue } from 'react-select'

const Search = ({
  setSelectedIngredients,
}: {
  setSelectedIngredients: (ingredients: Ingredient[]) => void
}) => {
  const [options, setOptions] = useState<SelectOption[]>([])

  const loadOptions = (
    inputValue: string,
    callback: (options: SelectOption[]) => void
  ) => {
    fetchIngredients({ name: inputValue }).then(async (response) => {
      if (response.status === 200) {
        const ingredients: Ingredient[] = await response.json()
        const newOptions = ingredients.map((ingredient: Ingredient) => {
          return { value: ingredient.id, label: ingredient.name }
        })
        setOptions(newOptions)

        callback(newOptions)
      } else {
        callback([])
      }
    })
  }

  const onChange = (selectedOptions: MultiValue<SelectOption>) => {
    const newSelectedIngredients = selectedOptions.map(
      (selectedOption: SelectOption) => {
        return { id: selectedOption.value, name: selectedOption.label }
      }
    )

    setSelectedIngredients(newSelectedIngredients)
  }

  return (
    <div className="ingredients-search container">
      <div className="row">
        <div className="col-xs-4">
          <div className="form-group">
            <AsyncSelect
              isMulti
              loadOptions={loadOptions}
              name="ingredients"
              options={options}
              className="basic-multi-select"
              classNamePrefix="select"
              placeholder="Enter here your ingredients..."
              onChange={onChange}
            />
          </div>
        </div>
      </div>
    </div>
  )
}

export default Search
