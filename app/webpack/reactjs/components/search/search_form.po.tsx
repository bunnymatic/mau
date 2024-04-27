import esSearchResults from "@fixtures/files/search_results.json";
import * as searchService from "@js/services/search.service";
import { BasePageObject } from "@reactjs/test/base_page_object";
import { render } from "@testing-library/react";
import React from "react";
import { type Mock, vi } from "vitest";

import { SearchForm } from "./search_form";
import { SearchResultsProvider } from "./search_results.context";
import { SearchResult } from "./searchTypes";

const mockSearchService = vi.fn();

export class SearchFormPageObject extends BasePageObject {
  mockSearchService: Mock;

  constructor({ debug, raiseOnFind } = {}) {
    super({ debug, raiseOnFind });
    this.mockSearchService = mockSearchService;
  }

  renderComponent(results?: SearchResult[]) {
    return render(
      <SearchResultsProvider initialResults={results ?? []}>
        <SearchForm />
      </SearchResultsProvider>
    );
  }

  setupApiMocks(success = true) {
    vi.spyOn(searchService, "query").mockImplementation(mockSearchService);
    if (success) {
      this.mockSearchService.mockResolvedValue(esSearchResults.hits.hits);
    } else {
      this.mockSearchService.mockRejectedValue("rats");
    }
  }

  get input() {
    return this.findInput("Search");
  }
}
