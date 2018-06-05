(function() {
  describe("mau.directives.editableContent", function() {
    beforeEach(module("mau.directives"));
    beforeEach(module("templates"));
    beforeEach(module("mau.services"));
    beforeEach(function() {
      return inject(function(objectRoutingService) {
        this.objectRoutingService = objectRoutingService;
        spyOn(objectRoutingService, "newCmsDocumentPath").and.returnValue(
          "/newPath"
        );
        spyOn(objectRoutingService, "editCmsDocumentPath").and.returnValue(
          "/editPath"
        );
      });
    });

    var editTemplate =
      "<div class='section editable markdown' data-cmsid='5' editable-content>existing stuff</div>";
    var newTemplate =
      "<div class='section editable markdown' data-page='the_page' data-section='the_section' editable-content>existing stuff</div>";
    var compiledTemplate;
    var scope = {};

    describe("with cms page and section", function() {
      beforeEach(function() {
        compiledTemplate = compileTemplate(newTemplate, scope);
      });
      it("renders the transcluded content and includes a link to the right place", function() {
        expect(
          $(compiledTemplate)
            .find("a")
            .attr("href")
        ).toEqual("/newPath");
      });
      it("calls the path constructor with the right stuff", function() {
        expect(
          this.objectRoutingService.newCmsDocumentPath
        ).toHaveBeenCalledWith({
          page: "the_page",
          section: "the_section"
        });
      });
    });
    describe("with cms id", function() {
      beforeEach(function() {
        compiledTemplate = compileTemplate(editTemplate, scope);
      });
      it("calls the path constructor with the right stuff", function() {
        expect(
          this.objectRoutingService.editCmsDocumentPath
        ).toHaveBeenCalledWith({ id: "5" });
      });
      it("renders the transcluded content and includes a link to the right place", function() {
        expect(
          $(compiledTemplate)
            .find("a")
            .attr("href")
        ).toEqual("/editPath");
        expect($(compiledTemplate).text()).toMatch("existing stuff");
      });
    });
  });
}.call(this));
