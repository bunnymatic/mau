import "angular-mocks";
import "./search.service";

import angular from "angular";
import expect from "expect";

describe("mau.services.searchService", function () {
  let service, http;
  const successCb = jest.fn();
  const errorCb = jest.fn();
  const successPayload = ["search_results"];
  const errorPayload = ["whatever"];

  beforeEach(() => {
    jest.resetAllMocks();
  });
  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function ($httpBackend, searchService) {
      service = searchService;
      http = $httpBackend;
    })
  );
  afterEach(function () {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });
  describe(".query", function () {
    it("calls the apps search endpoint", function () {
      const query = "the query string";
      const extras = { whatever: "man" };
      const expectedParams = { q: query, ...extras };
      http.expectPOST("/search.json", expectedParams).respond(successPayload);
      const response = service.query({
        query,
        success: successCb,
        error: errorCb,
        ...extras,
      });
      http.flush();
      response.then(function (_data) {
        expect(successCb).toHaveBeenCalledWith(successPayload);
      });
    });

    it("returns empty string if there is no query", function () {
      const query = "";
      const extras = { whatever: "man" };
      const response = service.query({
        query,
        success: successCb,
        error: errorCb,
        ...extras,
      });
      response.then(function (_data) {
        expect(successCb).toHaveBeenCalledWith([]);
      });
    });

    it("when there is an error it calls the error callback", function () {
      const query = "the query string";
      const extras = { whatever: "man" };
      const expectedParams = { q: query, ...extras };
      http
        .expectPOST("/search.json", expectedParams)
        .respond(404, errorPayload);
      const response = service.query({
        query,
        success: successCb,
        error: errorCb,
        ...extras,
      });
      http.flush();
      response.then(function (_data) {
        expect(errorCb).toHaveBeenCalledWith(errorPayload);
      });
    });
  });
});
