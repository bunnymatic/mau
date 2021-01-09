import "angular-mocks";
import "@services/favorites.service";
import "./favorite_this";

import { compileTemplate, triggerEvent } from "@support/angular_helpers";
import angular from "angular";
import expect from "expect";

describe("mau.directives.favoriteThis", function () {
  const objectTemplate = (type, id) =>
    `<favorite-this object-type='${type}' object-id='${id}'></favorite-this>`;
  const blankTemplate = "<favorite-this></favorite-this>";

  let favService;
  beforeEach(angular.mock.module("mau.directives"));
  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function (favoritesService) {
      favService = favoritesService;

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
