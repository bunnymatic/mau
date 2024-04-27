import React, { createContext, type FC, type ReactNode, useState } from "react";

import * as searchTypes from "./searchTypes";

export const SearchResultsContext =
  createContext<searchTypes.SearchResultsContext>({});
SearchResultsContext.displayName = "SearchResultsData";

interface SearchProviderProps {
  initialResults?: searchTypes.SearchResult[];
  children?: ReactNode;
  /* setResults: (results: searchTypes.SearchResult[]) => void;
   * loading: boolean;
   * setLoading: (loading: boolean) => void; */
}

export const SearchResultsProvider: FC<SearchProviderProps> = ({
  initialResults,
  children,
}) => {
  const [results, setResults] = useState<searchTypes.SearchResult[]>(
    initialResults ?? []
  );
  const [loading, setLoading] = useState<boolean>(false);
  return (
    <SearchResultsContext.Provider
      value={{ results, setResults, loading, setLoading }}
    >
      {children}
    </SearchResultsContext.Provider>
  );
};
