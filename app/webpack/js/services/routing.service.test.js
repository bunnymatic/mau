import { expect } from "vitest";

import { routing } from "./routing.service";

describe("mau.services.objectRoutingService", () => {
  describe("#editCmsDocumentPath", () => {
    it("returns the right path for an cms document with an id", () => {
      expect(
        routing.editCmsDocumentPath({
          id: "whatever",
        })
      ).toEqual("/admin/cms_documents/whatever/edit");
    });
  });
  describe("#newCmsDocumentPath", () => {
    it("returns the right path for an cms document with a page and section", () => {
      expect(
        routing.newCmsDocumentPath({
          page: "the_page",
          section: "the_section",
        })
      ).toEqual(
        "/admin/cms_documents/new?cms_document[page]=the_page&cms_document[section]=the_section"
      );
    });
  });
  describe("#artistPath", () => {
    it("returns the right path for an artist with an id", () => {
      expect(
        routing.artistPath({
          id: "whatever",
        })
      ).toEqual("/artists/whatever");
    });
    it("returns the right path for an artist with an slug", () => {
      expect(
        routing.artistPath({
          slug: "whatever",
        })
      ).toEqual("/artists/whatever");
    });
    it("returns the right path for an id", () => {
      expect(routing.artistPath("whatever")).toEqual("/artists/whatever");
    });
  });
  describe("#studioPath", () => {
    it("returns the right path for an artist with an id", () => {
      expect(
        routing.studioPath({
          id: "whatever",
        })
      ).toEqual("/studios/whatever");
    });
    it("returns the right path for an artist with an slug", () => {
      expect(
        routing.studioPath({
          slug: "whatever",
        })
      ).toEqual("/studios/whatever");
    });
    it("returns the right path for an id", () => {
      expect(routing.studioPath("whatever")).toEqual("/studios/whatever");
    });
  });
  describe("#artPiecePath", () => {
    it("returns the right path for an artist with an id", () => {
      expect(
        routing.artPiecePath({
          id: "whatever",
        })
      ).toEqual("/art_pieces/whatever");
    });
    it("returns the right path for an artist with an slug", () => {
      expect(
        routing.artPiecePath({
          slug: "whatever",
        })
      ).toEqual("/art_pieces/whatever");
    });
    it("returns the right path for an id", () => {
      expect(routing.artPiecePath("whatever")).toEqual("/art_pieces/whatever");
    });
  });
  describe("#urlForModel", () => {
    it("returns the right path for mediums", () => {
      expect(
        routing.urlForModel("medium", { id: "12", slug: "the-slug" })
      ).toEqual("/media/the-slug");
    });
    it("returns the right path for art_piece_tags", () => {
      expect(
        routing.urlForModel("art_piece_tag", { id: "12", slug: "the-slug" })
      ).toEqual("/art_piece_tags/the-slug");
    });
  });
});
