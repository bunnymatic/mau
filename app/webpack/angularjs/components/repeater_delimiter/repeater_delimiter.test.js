import "angular-mocks";
import "./repeater_delimiter";

import { compileTemplate } from "@test/support/angular_helpers";
import angular from "angular";
import expect from "expect";

describe("mau.directives.repeater_delimiter", function () {
  // ng-repeat can't be at the root node so we add `.container`
  const template =
    '<div class="container">' +
    '<div ng-repeat="thing in things" repeater-delimiter="DELIM">' +
    "{{thing}}" +
    "</div>" +
    "</div>";

  beforeEach(angular.mock.module("mau.directives"));

  let element;

  beforeEach(function () {
    const scope = {
      things: ["one", "two", "three"],
    };
    element = compileTemplate(template, scope);
  });

  it("renders a comma between each element", function () {
    expect(element.text()).toEqual("oneDELIMtwoDELIMthreeDELIM");
  });

  it("renders 3 divider spans", function () {
    const spans = element.find("span");
    expect(spans).toHaveLength(3);
    expect(spans[0].getAttribute("ng-show")).toEqual(" ! $last ");
  });
});
