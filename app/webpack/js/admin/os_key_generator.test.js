import expect from "expect";
import jQuery from "jquery";

import OsKeyGenerator from "./os_key_generator";

jest.dontMock("jquery");

describe("OsKeyGenerator", function () {
  beforeEach(function () {
    document.documentElement.innerHTML =
      "<div id=\"fixture\">\n  <form class='js-os-key-gen'>\n    <input id='start_date'></input>\n    <input id='end_date'></input>\n    <input id='os_key'></input>\n  </form>\n</div>";
    jQuery("#fixture input").val("");
  });
  describe("initialization", function () {
    it("sets the key if the start date is set", function () {
      jQuery("#start_date").val("1 January 2012");
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_field: "#start_date",
        end_date_field: "#end_date",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("201201");
    });
    it("does not set the key if start date is empty", function () {
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_field: "#start_date",
        end_date_field: "#end_date",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("");
    });
    it("does not set the key if start date is an invalid date", function () {
      jQuery("#start_date").val("whatever, yo");
      new OsKeyGenerator(jQuery("form.js-os-key-gen"), {
        start_date_field: "#start_date",
        end_date_field: "#end_date",
        key_field: "#os_key",
      });
      expect(jQuery("#fixture #os_key").val()).toEqual("");
    });
  });
});
