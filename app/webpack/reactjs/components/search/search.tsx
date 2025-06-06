import { SearchResultsProvider } from "@reactjs/components/search/search_results.context";
import React, { type ReactNode } from "react";

import { SearchForm } from "./search_form";
import { SearchResults } from "./search_results";

export const Search = (): ReactNode => {
  return (
    <SearchResultsProvider>
      <div className="search-wrapper">
        <SearchForm />
        <SearchResults />
      </div>
    </SearchResultsProvider>
  );
};
