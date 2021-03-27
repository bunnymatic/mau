import "angular-mocks";
import "./open_studios_registration.service";

import { api } from "@services/api";
import expect from "expect";

jest.mock("@services/api");

describe("mau.services.openStudiosRegistrationService", () => {
  let service;

  beforeEach(() => {
    angular.mock.module("mau.services");
    angular.mock.inject(function (openStudiosRegistrationService) {
      service = openStudiosRegistrationService;
    });
    return null;
  });

  describe(".register", () => {
    it("calls the right endpoint to register this artist for open studios", () => {
      const inputData = {
        participation: false,
      };
      const successResponse = {
        success: true,
        participating: false,
      };
      api.users.whoami = jest.fn().mockResolvedValue({
        currentUser: {
          id: 1,
          login: "the_user",
          slug: "the_user_slug",
        },
      });
      api.users.registerForOs.mockResolvedValue(successResponse);

      const response = service.register(inputData);
      response.then(function (_data) {
        expect(api.users.registerForOs).toHaveBeenCalledWith("the_user_slug", {
          participation: false,
        });
        expect(api.users.whoami).toHaveBeenCalled();
      });
    });

    it("raises if sommething goes wrong", () => {
      const inputData = {
        participation: false,
      };
      api.users.whoami = jest.fn().mockResolvedValue({
        currentUser: {
          id: 1,
          login: "the_user",
          slug: "the_user_slug",
        },
      });
      api.users.registerForOs = jest.fn().mockRejectedValue({});

      const response = service.register(inputData);
      response
        .then(function (_data) {
          // should never get here
          expect(true).toEqual(false);
        })
        .catch((_err) => {
          expect(api.users.registerForOs).toHaveBeenCalledWith(
            "the_user_slug",
            { participation: false }
          );
          expect(api.users.whoami).toHaveBeenCalled();
        });
    });
  });
});
