import expect from "expect";
import angular from "angular";
import "angular-mocks";
import "./current_user.service";

describe("mau.services.currentUserService", function () {
  let service, http;

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function ($httpBackend, currentUserService) {
      service = currentUserService;
      http = $httpBackend;
    })
  );
  afterEach(function () {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });
  describe(".get", function () {
    it("calls the apps current user endpoint", function () {
      const success = {
        current_user: { id: 1, login: "yo", slug: "yo" },
      };
      http.expect("GET", "/users/whoami").respond(success);
      const response = service.get();
      http.flush();
      response.then(function (data) {
        expect(data).toEqual(success);
      });
    });
  });
});
