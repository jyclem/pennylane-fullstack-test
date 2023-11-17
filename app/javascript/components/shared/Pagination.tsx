import React from 'react'

const Pagination = ({
  page,
  count,
  limit,
  fetch,
}: {
  page: Pagination['page']
  count: Pagination['count']
  limit: Pagination['limit']
  fetch: (page: number) => void
}) => (
  <div className="pagination">
    {page > 1 && <span onClick={() => fetch(page - 1)}>{'<'}</span>}
    {count / limit > 1 &&
      [...Array(Math.floor(count / limit + 1))].map((_, index) => (
        <span
          key={index}
          className={index + 1 === page ? 'selected' : ''}
          onClick={() => fetch(index + 1)}
        >
          {index + 1}
        </span>
      ))}
    {page < count / limit && <span onClick={() => fetch(page + 1)}>{'>'}</span>}
  </div>
)

export default Pagination
