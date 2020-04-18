import "@js/app/utils";

import expect from "expect";
import jQuery from "jquery";

import MarkItDown from "./mark_it_down";

jest.mock("@js/app/utils", () => ({
  debounce: (f, _t, _) => f(),
}));

jest.dontMock("jquery");

describe("MarkItDown", function () {
  let loadSpy;
  beforeEach(function () {
    loadSpy = jest.spyOn(jQuery.fn, "load");
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
