import expect from "expect";
import angular from "angular";
import "angular-mocks";
angular.module("TestApp", [
  "templates",
  "ngResource",
  "ngSanitize",
  "ngMocks",
  "ngDialog",
  "angularSlideables",
  "mau.models",
  "mau.services",
  "mau.directives",
]);
import "./currentUserService";

describe("mau.services.currentUserService", function () {
  let _service, _http, _q;

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(inject(function ($httpBackend, $q, currentUserService) {
    _service = currentUserService;
    _http = $httpBackend;
    _q = $q;
  }));
  afterEach(function () {
    _http.verifyNoOutstandingExpectation();
    _http.verifyNoOutstandingRequest();
  });
  describe(".get", function () {
    it("calls the apps current user endpoint", function () {
      var response, success;
      success = {
        current_user: { id: 1, login: "yo", slug: "yo" },
      };
      _http.expect("GET", "/users/whoami").respond(success);
      response = this.service.get();
      _http.flush();
      response.then(function (data) {
        expect(data).toEqual(success);
      });
    });
  });
});
