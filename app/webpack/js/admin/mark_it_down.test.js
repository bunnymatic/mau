import "@js/app/utils";

import jQuery from "jquery";
import { expect, vi } from "vitest";

import MarkItDown from "./mark_it_down";

vi.mock("@js/app/utils", () => ({
  debounce: (f, _t, _) => f(),
}));

describe("MarkItDown", function () {
  let loadSpy;
  beforeEach(function () {
    loadSpy = vi.spyOn(jQuery.fn, "load");
    document.documentElement.innerHTML =
      '<div id="fixture">' +
      '  <input id="input" value="# here we go"/>' +
      '  <div id="output" ></div>' +
      "</div>";
    new MarkItDown("#input", "#output", 1);
  });

  it("loads the marked down value in output after a change", () => {
    jQuery("#input").trigger("change");
    expect(loadSpy).toHaveBeenCalledWith("/admin/discount/markup", {
      markdown: "# here we go",
    });
  });
});
