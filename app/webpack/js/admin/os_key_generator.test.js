import "pickadate/lib/picker";
import "pickadate/lib/picker.date";
import "pickadate/lib/picker.time";

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
      "    <input class='js-datepicker' id='start_date_pickadate_hidden'></input>" +
      "    <input id='end_date'></input>" +
      "  <input id='os_key'></input>" +
      " </form>" +
      "</div>";
    jQuery("#fixture input").val("");
    jQuery(".js-datepicker").pickadate({
      min: new Date(),
    });
  });
  describe("initialization", function () {
    it("sets the key if the start date is set", function () {
      jQuery("#start_date_pickadate_hidden").val("2012-01-10");
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
    it("does not set the key if start date is an invalid date", function () {
      jQuery("#start_date_pickadate_hidden").val("2012-xx-10");
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_field: "#start_date",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("");
    });
  });
});
