import jQuery from "jquery";
import { beforeEach, describe, expect, it, vi } from "vitest";

import ArtistsAdminIndex from "./artists_admin_index";

describe("ArtistsAdminIndex", function () {
  let loadSpy;
  beforeEach(function () {
    loadSpy = vi.spyOn(jQuery.fn, "load");
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
