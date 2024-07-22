import jQuery from "jquery";
import { beforeEach, describe, expect, it } from "vitest";

import Flash from "./flash";

describe("Flash", function () {
  beforeEach(function () {
    document.documentElement.innerHTML =
      '<div id="fixture"><div class="container"></div></div>';
  });

  describe("show", function () {
    beforeEach(function () {
      var jsf = jQuery("#jsFlash");
      if (jsf) {
        jsf.remove();
      }
    });
    it("draws an error div", function () {
      var f = new Flash();
      f.show({ error: "this is the new error" });
      expect(jQuery("#jsFlash .flash__error").html()).toContain(
        "this is the new error"
      );
    });

    it("draws an error div in the container", function () {
      var f = new Flash();
      f.show({ error: "this is the new error" }, "#fixture .container");
      expect(jQuery("#fixture .flash__error").html()).toContain(
        "this is the new error"
      );
    });

    it("draws an notice div", function () {
      var f = new Flash();
      f.show({ notice: "this is the notice" });
      expect(jQuery("#jsFlash .flash__notice").html()).toContain(
        "this is the notice"
      );
    });
  });
});
