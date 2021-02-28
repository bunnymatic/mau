import "angular-mocks";
import "./share_button";

import { compileTemplate } from "@test/support/angular_helpers";
import angular from "angular";
import expect from "expect";

describe("mau.directives.shareButton", function () {
  const objectTemplate = (type) =>
    `<share-button type='${type}'></share-button>`;

  beforeEach(angular.mock.module("mau.directives"));

  let element;
  let artPiece = {
    id: 12,
    title: "Mona Lisa",
    artistName: "Leo",
    imageUrls: {
      large: "the_image.jpg",
    },
  };

  describe("when there is no art piece id", function () {
    beforeEach(() => {
      spyOn(console, "error");
      element = compileTemplate(objectTemplate("facebook"), {});
    });

    it("renders nothing", function () {
      expect(element.text().trim()).toEqual("");
      expect(element.find("a")).toHaveLength(0);
      expect(element.find("i")).toHaveLength(0);
    });

    it("logs an error", function () {
      expect(console.error).toHaveBeenCalledWith(
        "Nothing to render as there is no art piece"
      );
    });
  });

  describe("when it's a facebook share", function () {
    beforeEach(() => {
      element = compileTemplate(objectTemplate("facebook"), { artPiece });
    });

    it("includes the facebook icon", function () {
      const icon = element.find("i")[0];
      expect(icon.classList).toContain("ico-facebook");
      expect(icon.classList).toContain("ico-invert");
    });

    it("includes a facebook share link", function () {
      const link = element.find("a")[0];
      expect(link.href).toMatch(/\/\/www\.facebook\.com\/sharer\/sharer.php\?/);
      expect(link.href).toContain("server%2Fart_pieces%2F12");
    });
  });

  describe("when it's a twitter share", function () {
    beforeEach(() => {
      element = compileTemplate(objectTemplate("twitter"), { artPiece });
    });

    it("includes the twitter icon", function () {
      const icon = element.find("i")[0];
      expect(icon.classList).toContain("ico-twitter");
      expect(icon.classList).toContain("ico-invert");
    });

    it("includes a twitter share link", function () {
      const link = element.find("a")[0];
      expect(link.href).toMatch(/\/\/twitter\.com\/intent\/tweet\?/);
      expect(link.href).toContain(
        "text=Check%20out%20Mona%20Lisa%20by%20Leo%20on%20Mission%20Artists"
      );
      expect(link.href).toContain("&via=sfmau");
      expect(link.href).toMatch(/url=.*server%2Fart_pieces%2F12/);
    });
  });

  describe("when it's a pinterest share", function () {
    beforeEach(() => {
      element = compileTemplate(objectTemplate("pinterest"), { artPiece });
    });

    it("includes the pinterest icon", function () {
      const icon = element.find("i")[0];
      expect(icon.classList).toContain("ico-pinterest");
      expect(icon.classList).toContain("ico-invert");
    });

    it("includes a pinterest share link", function () {
      const link = element.find("a")[0];
      expect(link.href).toMatch(/\/\/pinterest\.com\/pin\/create\/button\/?/);
      expect(link.href).toMatch(/url=.*server%2Fart_pieces%2F12/);
      expect(link.href).toContain("title=Mona%20Lisa");
      expect(link.href).toContain(
        "description=Check%20out%20Mona%20Lisa%20by%20Leo%20on%20Mission%20Artists"
      );
      expect(link.href).toContain("&media=the_image.jpg");
    });
  });
});
