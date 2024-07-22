import jQuery from "jquery";
import { beforeEach, describe, expect, it } from "vitest";

import WhatsThisPopup from "./whats_this_popup";

describe("WhatsThisPopup", function () {
  beforeEach(() => {
    const whatsThis =
      '<a href="#" class="the-trigger" data-parent="pear">?</a>' +
      '<div id="pearcontainer"  style="display:none;">these are the goods</div>';

    document.documentElement.innerHTML =
      '<div id="fixture">' +
      `<div class="container">${whatsThis}</div>` +
      "</div>";

    new WhatsThisPopup(".the-trigger");
    expect(jQuery("#pearcontainer").css("display")).toEqual("none");
  });

  it("opens when you click the trigger", () => {
    jQuery(".the-trigger").trigger("click");
    expect(jQuery("#pearcontainer").css("display")).toEqual("block");
  });

  it("closes when you click the data", () => {
    jQuery(".the-trigger").trigger("click");
    expect(jQuery("#pearcontainer").css("display")).toEqual("block");
    jQuery("#pearcontainer").trigger("click");
    expect(jQuery("#pearcontainer").css("display")).toEqual("none");
  });

  it("closes when you click the trigger again", () => {
    jQuery(".the-trigger").trigger("click");
    expect(jQuery("#pearcontainer").css("display")).toEqual("block");
    jQuery(".the-trigger").trigger("click");
    expect(jQuery("#pearcontainer").css("display")).toEqual("none");
  });
});
