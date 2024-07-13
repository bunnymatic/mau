import esSearchResults from "@fixtures/files/search_results.json";
import { SearchHit } from "@js/app/models/search_hit.model";
import * as searchService from "@js/services/search.service";
import {
  BasePageObject,
  BasePageObjectProps,
} from "@reactjs/test/base_page_object";
import { render } from "@testing-library/react";
import React from "react";
import { type Mock, vi } from "vitest";

import { SearchForm } from "./search_form";
import { SearchResultsProvider } from "./search_results.context";

const mockSearchService = vi.fn();

export class SearchFormPageObject extends BasePageObject {
  mockSearchService: Mock;

  constructor(args: BasePageObjectProps = {}) {
    super(args);
    this.mockSearchService = mockSearchService;
  }

  renderComponent(results?: SearchHit[]) {
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
