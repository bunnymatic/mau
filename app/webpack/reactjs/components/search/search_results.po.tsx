import { SearchHit } from "@js/app/models/search_hit.model";
import { SearchResultsProvider } from "@reactjs/components/search/search_results.context";
import { BasePageObject } from "@reactjs/test/base_page_object";
import { render, screen } from "@testing-library/react";
import React from "react";

import { SearchResults } from "./search_results";

export class SearchResultsPageObject extends BasePageObject {
  public results: SearchHit[];
  constructor() {
    super();
    this.results = [];
  }

  renderComponent() {
    return render(
      <SearchResultsProvider initialResults={this.results}>
        <SearchResults />
      </SearchResultsProvider>
    );
  }

  setResults(results) {
    this.results = results;
  }

  imageLink(hit: SearchHit) {
    return screen.getAllByTitle(hit.name)[0] as HTMLLinkElement;
  }

  mainLink(hit: SearchHit) {
    return screen.getAllByTitle(hit.name)[1] as HTMLLinkElement;
  }
}
