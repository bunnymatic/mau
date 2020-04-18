import "angular-mocks";
import "./current_user.service";
import "./open_studios_registration.service";

import angular from "angular";
import expect from "expect";

describe("mau.services.openStudiosRegistrationService", () => {
  let service, http;

  beforeEach(() => {
    angular.mock.module("mau.services");
    angular.mock.inject(function (
      $httpBackend,
      openStudiosRegistrationService
    ) {
      service = openStudiosRegistrationService;
      http = $httpBackend;
    });
    return null;
  });
  afterEach(() => {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });

  describe(".register", () => {
    it("calls the right endpoint to register this artist for open studios", () => {
      const success = jest.fn();
      const failure = jest.fn();
      const inputData = {
        participation: false,
      };
      const successResponse = {
        success: true,
        participating: false,
      };
      http.when("GET", "/users/whoami").respond({
        current_user: {
          id: 1,
          login: "the_user",
          slug: "the_user_slug",
        },
      });
      http
        .expect("POST", "/api/artists/the_user_slug/register_for_open_studios")
        .respond(successResponse);

      const response = service.register(inputData, success, failure);
      http.flush();
      response.then(function (_data) {
        expect(success).toHaveBeenCalled();
      });
    });

    it("calls the failure callback if sommething goes wrong", () => {
      const success = jest.fn();
      const failure = jest.fn();
      const inputData = {
        participation: false,
      };
      http.when("GET", "/users/whoami").respond({
        current_user: {
          id: 1,
          login: "the_user",
          slug: "the_user_slug",
        },
      });
      http
        .expect("POST", "/api/artists/the_user_slug/register_for_open_studios")
        .respond(400, {});

      const response = service.register(inputData, success, failure);
      http.flush();
      response.then(function (_data) {
        expect(failure).toHaveBeenCalled();
      });
    });
  });
});
