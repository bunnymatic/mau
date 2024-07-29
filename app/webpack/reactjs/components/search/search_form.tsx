import { debounce } from "@js/app/utils";
import * as searchService from "@js/services/search.service";
import { useSearchResultsContext } from "@reactjs/components/search/search_results.context";
import React, { type FC, useCallback } from "react";

interface SearchFormProps {}
import { SearchHit } from "@js/app/models/search_hit.model";

export const SearchForm: FC<SearchFormProps> = () => {
  const { setResults, setLoading } = useSearchResultsContext();
  const pageSize = 20;
  const page = 0;

  const executeSearch = useCallback(
    debounce(
      (query) => {
        setLoading(true);
        return searchService
          .query({
            query: query,
            size: pageSize,
            page: page,
          })
          .then((results) => {
            setLoading(false);
            const hits = results
              .filter((x) => Boolean(x))
              .map((datum) => new SearchHit(datum));
            setResults(hits);
          })
          .catch((err) => {
            setLoading(false);
            console.error(err);
          });
      },
      250,
      false
    ),
    [page, pageSize, setLoading, setResults]
  );

  return (
    <form action="/search" method="POST">
      <a className="submit-button" href="#">
        <i className="icon fa fa-search"></i>
      </a>
      <label htmlFor="search_query" style={{ display: "none" }}>
        Search
      </label>
      <input
        onChange={(e) => {
          executeSearch(e.target.value);
        }}
        autoComplete="off"
        autoFocus
        id="search_query"
        name="q"
        type="text"
      />
    </form>
  );
};
