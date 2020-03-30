import expect from "expect";
import angular from "angular";
import "angular-mocks";
import "./object_routing_service";

describe("mau.services.objectRoutingService", () => {
  let service;

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(
      (objectRoutingService) => (service = objectRoutingService)
    )
  );

  describe("#editCmsDocumentPath", () => {
    it("returns the right path for an cms document with an id", () => {
      expect(
        service.editCmsDocumentPath({
          id: "whatever",
        })
      ).toEqual("/admin/cms_documents/whatever/edit");
    });
  });
  describe("#newCmsDocumentPath", () => {
    it("returns the right path for an cms document with a page and section", () => {
      expect(
        service.newCmsDocumentPath({
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
        service.artistPath({
          id: "whatever",
        })
      ).toEqual("/artists/whatever");
    });
    it("returns the right path for an artist with an slug", () => {
      expect(
        service.artistPath({
          slug: "whatever",
        })
      ).toEqual("/artists/whatever");
    });
    it("returns the right path for an id", () => {
      expect(service.artistPath("whatever")).toEqual("/artists/whatever");
    });
  });
  describe("#studioPath", () => {
    it("returns the right path for an artist with an id", () => {
      expect(
        service.studioPath({
          id: "whatever",
        })
      ).toEqual("/studios/whatever");
    });
    it("returns the right path for an artist with an slug", () => {
      expect(
        service.studioPath({
          slug: "whatever",
        })
      ).toEqual("/studios/whatever");
    });
    it("returns the right path for an id", () => {
      expect(service.studioPath("whatever")).toEqual("/studios/whatever");
    });
  });
  describe("#artPiecePath", () => {
    it("returns the right path for an artist with an id", () => {
      expect(
        service.artPiecePath({
          id: "whatever",
        })
      ).toEqual("/art_pieces/whatever");
    });
    it("returns the right path for an artist with an slug", () => {
      expect(
        service.artPiecePath({
          slug: "whatever",
        })
      ).toEqual("/art_pieces/whatever");
    });
    it("returns the right path for an id", () => {
      expect(service.artPiecePath("whatever")).toEqual("/art_pieces/whatever");
    });
  });
});
