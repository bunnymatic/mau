import { SearchHit } from "@js/app/models/search_hit.model";
import { Dispatch, SetStateAction } from "react";

export interface SearchResult {}
export interface SearchResultsContext {
  results: SearchHit[];
  loading: boolean | undefined;
  setResults: Dispatch<SetStateAction<SearchHit[]>>;
  setLoading: Dispatch<SetStateAction<boolean>>;
}
