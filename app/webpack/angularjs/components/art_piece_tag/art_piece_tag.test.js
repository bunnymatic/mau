import expect from "expect";
import angular from "angular";
import "angular-mocks";
import "./art_piece_tag";
import "@services/object_routing.service";
import { compileTemplate } from "@support/angular_helpers";

describe("mau.directives.artPieceTag", function () {
  beforeEach(angular.mock.module("mau.directives"));
  beforeEach(angular.mock.module("mau.services"));
  beforeEach(angular.mock.module("ngSanitize"));

  describe("with only the text attribute", function () {
    let element;

    beforeEach(function () {
      element = compileTemplate('<art-piece-tag tag="tag" />', {
        tag: { name: "my tag", id: 12 },
      });
    });

    it("uses tag name as the link text", function () {
      expect(element.text()).toEqual("my tag");
    });

    it("uses tag path as the link", function () {
      expect(element.find("a").attr("href")).toEqual("/art_piece_tags/12");
    });
  });
});
