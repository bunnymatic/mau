import esSearchResults from "@fixtures/files/search_results.json";
import * as searchService from "@js/services/search.service";
import { BasePageObject } from "@reactjs/test/base_page_object";
import { render } from "@testing-library/react";
import React from "react";
import { mocked } from "ts-jest/utils";

import { SearchForm } from "./search_form";

jest.mock("@js/services/search.service");

const mockSearchService = mocked(searchService, true);

const mockSetLoading = jest.fn();
const mockSetResults = jest.fn();

jest.mock("react", () => {
  const ActualReact = jest.requireActual("react");
  return {
    ...ActualReact,
    useContext: () => ({
      setLoading: mockSetLoading,
      setResults: mockSetResults,
    }),
  };
});

export class SearchFormPageObject extends BasePageObject {
  mockSearchService: jest.Mock;
  mockSetLoading: jest.Mock;
  mockSetResults: jest.Mock;

  constructor({ debug, raiseOnFind } = {}) {
    super({ debug, raiseOnFind });
    this.mockSearchService = mockSearchService;
    this.mockSetLoading = mockSetLoading;
    this.mockSetResults = mockSetResults;
  }

  renderComponent() {
    return render(<SearchForm />);
  }

  setupApiMocks(success = true) {
    if (success) {
      mockSearchService.query.mockResolvedValue(esSearchResults.hits.hits);
    } else {
      mockSearchService.query.mockRejectedValue("rats");
    }
  }

  get input() {
    return this.findInput("Search");
  }
}
