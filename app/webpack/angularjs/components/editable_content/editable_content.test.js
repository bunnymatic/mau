import "angular-mocks";
import "@services/object_routing.service";
import "./editable_content";

import { compileTemplate } from "@support/angular_helpers";
import angular from "angular";
import expect from "expect";

describe("mau.directives.editableContent", () => {
  let routingService;
  beforeEach(angular.mock.module("mau.directives"));
  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function (objectRoutingService) {
      routingService = objectRoutingService;
      jest
        .spyOn(routingService, "newCmsDocumentPath")
        .mockReturnValue("/newPath");
      jest
        .spyOn(routingService, "editCmsDocumentPath")
        .mockReturnValue("/editPath");
    })
  );

  const editTemplate =
    "<div class='section editable markdown' data-cmsid='5' editable-content>existing stuff</div>";
  const newTemplate =
    "<div class='section editable markdown' data-page='the_page' data-section='the_section' editable-content>existing stuff</div>";
  let compiledTemplate;
  const scope = {};

  describe("with cms page and section", () => {
    beforeEach(() => {
      compiledTemplate = compileTemplate(newTemplate, scope);
    });
    it("renders the transcluded content and includes a link to the right place", () => {
      expect(compiledTemplate.find("a").attr("href")).toEqual("/newPath");
    });
    it("calls the path constructor with the right stuff", () => {
      expect(routingService.newCmsDocumentPath).toHaveBeenCalledWith({
        page: "the_page",
        section: "the_section",
      });
    });
  });
  describe("with cms id", () => {
    beforeEach(() => {
      compiledTemplate = compileTemplate(editTemplate, scope);
    });
    it("calls the path constructor with the right stuff", () => {
      expect(routingService.editCmsDocumentPath).toHaveBeenCalledWith({
        id: "5",
      });
    });
    it("renders the transcluded content and includes a link to the right place", () => {
      expect(compiledTemplate.find("a").attr("href")).toEqual("/editPath");
      expect(compiledTemplate.text()).toMatch("existing stuff");
    });
  });
});
