import expect from "expect";
import angular from "angular";
import "angular-mocks";
import "@services/current_user.service";
import "@services/favorites.service";
import { compileTemplate, triggerEvent } from "@support/angular_helpers";
import "./favorite_this";

describe("mau.directives.favoriteThis", function () {
  const objectTemplate = (type, id) =>
    `<favorite-this object-type='${type}' object-id='${id}'></favorite-this>`;
  const blankTemplate = "<favorite-this></favorite-this>";

  let favService, userService;
  beforeEach(angular.mock.module("mau.directives"));
  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function (currentUserService, favoritesService) {
      favService = favoritesService;
      userService = currentUserService;

      jest
        .spyOn(userService, "get")
        .mockResolvedValue({ current_user: "bmatic" });
      jest
        .spyOn(favService, "add")
        .mockResolvedValue({ artist: { id: "artistid" } });
    })
  );
  describe("with an art piece", function () {
    beforeEach(() => {});

    it("sets up the directive with the art piece attributes", function () {
      var args, e;
      e = compileTemplate(objectTemplate("Artist", 10), {});
      triggerEvent(e, "click");
      expect(favService.add).toHaveBeenCalled();
      args = favService.add.mock.calls[0];
      expect(args).toEqual(["Artist", "10"]);
    });
    it("submits a request to favorite that art piece when clicked on", function () {
      var args, e;
      e = compileTemplate(objectTemplate("ArtPiece", 20));
      triggerEvent(e, "click");
      expect(favService.add).toHaveBeenCalled();
      args = favService.add.mock.calls[0];
      expect(args).toEqual(["ArtPiece", "20"]);
    });
    it("calls the service with empties if there is no object or id", function () {
      var args, e;
      e = compileTemplate(blankTemplate);
      triggerEvent(e, "click");
      expect(favService.add).toHaveBeenCalled();
      args = favService.add.mock.calls[0];
      expect(args).toEqual([void 0, void 0]);
    });
  });
});
