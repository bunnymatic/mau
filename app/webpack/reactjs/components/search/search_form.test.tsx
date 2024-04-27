import { act, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it } from "vitest";

import { SearchFormPageObject } from "./search_form.po";

describe("SearchForm", () => {
  let po: SearchFormPageObject;

  beforeEach(() => {
    po = new SearchFormPageObject();
  });

  describe("when there are results", () => {
    beforeEach(() => {
      po.setupApiMocks();
    });

    it("makes a query based on the input", async () => {
      act(() => {
        po.renderComponent();
      });

      await waitFor(() => {
        expect(po.input).toBeInTheDocument();
      });

      act(() => {
        po.fillInInput(po.input, "who");
      });

      await waitFor(() => {
        expect(po.mockSearchService).toHaveBeenCalledWith({
          page: 0,
          query: "who",
          size: 20,
        });
      });
    });
  });
});
