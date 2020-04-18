import expect from "expect";
import angular from "angular";
import "angular-mocks";
import { compileTemplate } from "@support/angular_helpers";
import "./notify_mau";
import "@services/notification.service";

describe("mau.directives.notifyMau", function () {
  const notifyTemplate = (type, linkText, withIcon) =>
    `<notify-mau note-type="${type}" link-text="${linkText}" ${
      !!withIcon && "with-icon"
    } email="whomever@example.com">`;

  beforeEach(angular.mock.module("mau.directives"));
  beforeEach(angular.mock.module("mau.services"));

  describe("with an icon", function () {
    let template;
    beforeEach(() => {
      template = compileTemplate(notifyTemplate("help", "", true));
    });

    it("includes an email icon", function () {
      expect(template.find("a").find("i").length).toEqual(1);
    });
  });

  describe("without an icon", function () {
    let template;
    beforeEach(() => {
      template = compileTemplate(notifyTemplate("help", "", false));
    });

    it("does not render an icon", function () {
      expect(template.find("a").find("i").length).toEqual(0);
    });
  });

  describe("with an link text", function () {
    let template;
    beforeEach(() => {
      template = compileTemplate(notifyTemplate("help", "the link", true));
    });

    it("includes the text", function () {
      expect(template.find("a").text()).toContain("the link");
    });
  });
});
