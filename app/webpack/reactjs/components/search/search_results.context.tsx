import { SearchHit } from "@js/app/models/search_hit.model";
import React, { createContext, type FC, type ReactNode, useState } from "react";

import * as searchTypes from "./searchTypes";

export const SearchResultsContext =
  createContext<searchTypes.SearchResultsContext>({
    results: [],
    loading: false,
    setLoading: (_loading) => {},
    setResults: (_results) => {},
  });
SearchResultsContext.displayName = "SearchResultsData";

interface SearchProviderProps {
  initialResults?: SearchHit[];
  children?: ReactNode;
  /* setResults: (results: searchTypes.SearchResult[]) => void;
   * loading: boolean;
   * setLoading: (loading: boolean) => void; */
}

export const SearchResultsProvider: FC<SearchProviderProps> = ({
  initialResults,
  children,
}) => {
  const [results, setResults] = useState<SearchHit[]>(initialResults ?? []);
  const [loading, setLoading] = useState<boolean>(false);
  return (
    <SearchResultsContext.Provider
      value={{ results, setResults, loading, setLoading }}
    >
      {children}
    </SearchResultsContext.Provider>
  );
};
