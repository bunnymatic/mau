import expect from "expect";
import angular from "angular";
import "angular-mocks";
import "./studios.service";

describe("mau.services.studiosService", function () {
  let service, http;

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function ($httpBackend, studiosService) {
      service = studiosService;
      http = $httpBackend;
    })
  );
  afterEach(function () {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });
  describe(".get", function () {
    it("calls the studios api endpoint", function () {
      const studio = { id: 10, name: "Artperson" };
      http.expectGET(`/api/v2/studios/${studio.id}.json`).respond({
        studio,
      });
      const response = service.get(studio.id);
      http.flush();
      response.$promise.then(function (data) {
        expect(data.toJSON()).toEqual(studio);
      });
    });

    it("looks for independent if there is no id", function () {
      const studio = { slug: "independent-studios" };

      http.expectGET(`/api/v2/studios/independent-studios.json`).respond({
        studio,
      });
      const response = service.get(null);
      http.flush();
      response.$promise.then(function (data) {
        expect(data.toJSON()).toEqual(studio);
      });
    });
  });
});
