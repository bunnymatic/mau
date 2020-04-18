import "angular-mocks";
import "./current_user.service";
import "./favorites.service";

import angular from "angular";
import expect from "expect";

describe("mau.services.favoriteService", function () {
  let httpBackend, service;

  beforeEach(function () {
    angular.mock.module("mau.services");
    angular.mock.inject(function ($httpBackend, favoritesService) {
      httpBackend = $httpBackend;
      service = favoritesService;
    });
  });

  afterEach(function () {
    httpBackend.verifyNoOutstandingExpectation();
    httpBackend.verifyNoOutstandingRequest();
  });

  describe(".add", function () {
    it("calls the right endpoint to add this favorite if there is a logged in user", function () {
      var expectedPost, id, response, success, type;
      type = "Artist";
      id = "12";
      success = {
        message: "eat at joes",
      };
      expectedPost = {
        favorite: {
          type: type,
          id: id,
        },
      };
      httpBackend.when("GET", "/users/whoami").respond({
        current_user: {
          id: 1,
          login: "the_user",
          slug: "the_user_slug",
        },
      });
      httpBackend
        .expect("POST", "/users/the_user_slug/favorites", expectedPost)
        .respond(success);
      response = service.add(type, id);
      httpBackend.flush();
      response.then(function (data) {
        expect(data.message).toEqual("eat at joes");
      });
    });
    it("returns a message if there is not a logged in user", function () {
      var response;
      httpBackend.when("GET", "/users/whoami").respond({});
      response = service.add("the_type", "the_id");
      httpBackend.flush();
      response.then(function (data) {
        expect(data.message).toEqual(
          "You need to login before you can favorite things"
        );
      });
    });
    it("returns a message if there is favoriting fails", function () {
      var expectedPost, response;
      expectedPost = {
        favorite: {
          type: null,
          id: null,
        },
      };
      httpBackend.when("GET", "/users/whoami").respond({
        current_user: {
          id: 1,
          login: "somebody",
          slug: "somebody_slug",
        },
      });
      httpBackend
        .expect("POST", "/users/somebody_slug/favorites", expectedPost)
        .respond(500, {});
      response = service.add(null, null);
      httpBackend.flush();
      response.then(function (data) {
        expect(data).toEqual({
          message:
            "That item doesn't seem to be available to favorite.  If you think it should be, please drop us a note and we'll look into it.",
        });
      });
    });
  });
});
