import { SearchResultsProvider } from "@reactjs/components/search/search_results.context";
import React, { FC } from "react";

import { SearchForm } from "./search_form";
import { SearchResults } from "./search_results";

interface SearchProps {}

export const Search: FC<SearchProps> = () => {
  return (
    <SearchResultsProvider>
      <div className="search-wrapper">
        <SearchForm />
        <SearchResults />
      </div>
    </SearchResultsProvider>
  );
};
