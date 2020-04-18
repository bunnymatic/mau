import "angular-mocks";
import "./artists.service";

import angular from "angular";
import expect from "expect";

describe("mau.services.artistsService", function () {
  let service, http;

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function ($httpBackend, artistsService) {
      service = artistsService;
      http = $httpBackend;
    })
  );
  afterEach(function () {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });
  describe(".get", function () {
    it("calls the artists api endpoint", function () {
      const artist = { id: 10, first_name: "Artperson" };
      http.expectGET(`/api/v2/artists/${artist.id}.json`).respond({
        artist,
      });
      const response = service.get(artist.id);
      http.flush();
      response.$promise.then(function (data) {
        expect(data.toJSON()).toEqual(artist);
      });
    });
  });
});
