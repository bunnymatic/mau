import expect from "expect";
import jQuery from "jquery";

import OsKeyGenerator from "./os_key_generator";

jest.dontMock("jquery");

describe("OsKeyGenerator", function () {
  beforeEach(function () {
    document.documentElement.innerHTML =
      '<div id="fixture">' +
      " <form class='js-os-key-gen'>" +
      "    <input id='start_date'></input>" +
      "    <input id='start_date_pickadate_hidden'></input>" +
      "    <input id='end_date'></input>" +
      "  <input id='os_key'></input>" +
      " </form>" +
      "</div>";
    jQuery("#fixture input").val("");
  });
  describe("initialization", function () {
    it("sets the key if the start date is set", function () {
      jQuery("#start_date_pickadate_hidden").val("2012-01-10");
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_on_change_field: "#start_date",
        start_date_value_field: "#start_date_pickadate_hidden",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("201201");
    });
    it("does not set the key if start date is empty", function () {
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_on_change_field: "#start_date",
        start_date_value_field: "#start_date_pickadate_hidden",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("");
    });
    it("does not set the key if start date is an invalid date", function () {
      jQuery("#start_date_pickadate_hidden").val("2012-xx-10");
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_on_change_field: "#start_date",
        start_date_value_field: "#start_date_pickadate_hidden",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("");
    });
  });
});
