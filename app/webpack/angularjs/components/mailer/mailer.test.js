import "angular-mocks";
import "./mailer";
import "@services/mailer.service";

import { compileTemplate } from "@support/angular_helpers";
import angular from "angular";
import expect from "expect";

describe("mau.directives.mailer", function () {
  let $location;

  beforeEach(angular.mock.module("mau.directives"));
  beforeEach(angular.mock.module("mau.services"));
  beforeEach(function () {
    $location = "default";
    angular.mock.module(function ($provide) {
      $provide.value("$location", $location);
    });
  });

  describe("with only the text attribute", function () {
    let element;

    beforeEach(function () {
      element = compileTemplate('<mailer text="here we go" />');
    });

    it("uses text as the link text", function () {
      expect(element.text()).toEqual("here we go");
    });

    // Can't figure out how to trigger click
    // it("sets up the directive to email to www@missionartistunited.org with no subject", function() {

    //   expect($location).toEqual("something ");
    // });
  });
});
