import { api } from "@services/api";
import { beforeEach, describe, expect, it, vi } from "vitest";

import * as searchService from "./search.service";

vi.mock("@services/api");

describe("mau.services.searchService", function () {
  const successPayload = ["search_results"];
  beforeEach(() => {
    vi.resetAllMocks();
  });

  describe(".query", function () {
    it("calls the apps search endpoint", function () {
      api.search.query = vi.fn().mockResolvedValue(successPayload);
      const query = "the query string";
      const extras = { whatever: "man" };
      const expectedParams = { q: query, ...extras };
      const response = searchService.query({
        query,
        ...extras,
      });
      response.then((resp) => {
        expect(api.search.query).toHaveBeenCalledWith(expectedParams);
        expect(resp).toEqual(successPayload);
      });
    });

    it("returns empty array if there is no query", function () {
      const query = "";
      const extras = { whatever: "man" };
      const response = searchService.query({
        query,
        ...extras,
      });
      response.then(function (data) {
        expect(api.search.query).not.toHaveBeenCalled();
        expect(data).toEqual([]);
      });
    });

    it("when there is an error it raises", function () {
      const query = "the query string";
      const extras = { whatever: "man" };
      const expectedParams = { q: query, ...extras };
      api.search.query = vi.fn().mockRejectedValue(new Error("oops"));
      const response = searchService.query({
        query,
        ...extras,
      });
      response
        .then(() => {
          // should not end up here
          expect(true).toEqual(false);
        })
        .catch(function (_data) {
          expect(api.search.query).toHaveBeenCalledWith(expectedParams);
          expect(_data).toEqual(new Error("oops"));
        });
    });
  });
});
