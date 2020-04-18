import expect from "expect";
import jQuery from "jquery";

import ArtistsAdminIndex from "./artists_admin_index";

jest.dontMock("jquery");

describe("ArtistsAdminIndex", function () {
  let loadSpy;
  beforeEach(function () {
    loadSpy = jest.spyOn(jQuery.fn, "load");
    document.documentElement.innerHTML =
      '<div id="fixture">' +
      '<div class="tabs">' +
      '  <div id="good" class="tab-pane active" data-url="/admin/artists/good"/>' +
      '  <div id="pending" class="tab-pane active" data-url="/admin/artists/pending"/>' +
      '  <div id="bad" class="tab-pane active" data-url="/admin/artists/bad"/>' +
      "</div>";
    new ArtistsAdminIndex(".tabs [data-url]");
  });

  it("loads each url datatables for each tab", () => {
    expect(loadSpy).toHaveBeenCalledWith(
      "/admin/artists/good",
      { method: "post" },
      expect.any(Function)
    );
    expect(loadSpy).toHaveBeenCalledWith(
      "/admin/artists/pending",
      { method: "post" },
      expect.any(Function)
    );
    expect(loadSpy).toHaveBeenCalledWith(
      "/admin/artists/bad",
      { method: "post" },
      expect.any(Function)
    );
  });
});
