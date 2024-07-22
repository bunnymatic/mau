import jQuery from "jquery";
import { beforeEach, describe, expect, it } from "vitest";

import OsKeyGenerator from "./os_key_generator";

describe("OsKeyGenerator", function () {
  beforeEach(function () {
    document.documentElement.innerHTML =
      '<div id="fixture">' +
      " <form class='js-os-key-gen'>" +
      "    <input class='js-datepicker' id='start_date'></input>" +
      "    <input id='end_date'></input>" +
      "  <input id='os_key'></input>" +
      " </form>" +
      "</div>";
    jQuery("#fixture input").val("");
  });
  describe("initialization", function () {
    it("sets the key if the start date is set", function () {
      jQuery("#start_date").val("2012-01-10");
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_field: "#start_date",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("201201");
    });
    it("does not set the key if start date is empty", function () {
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_field: "#start_date",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("");
    });
  });
});
