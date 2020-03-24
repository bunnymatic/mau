/*eslint no-unused-vars: "off"*/

(function () {
  describe("mau.directives.mailer", function () {
    var $window;

    beforeEach(module("mau.directives"));
    beforeEach(module("templates"));
    beforeEach(module("mau.services"));
    beforeEach(function () {
      $window = { location: "default" };
      module(function ($provide) {
        $provide.value("$window", $window);
      });
    });

    return describe("with only the text attribute", function () {
      var scope;
      scope = {};
      var element;

      beforeEach(function () {
        element = compileTemplate('<mailer text="here we go" />');
      });

      it("uses text as the link text", function () {
        expect(element.text()).toEqual("here we go");
      });

      // it("sets up the directive to email to www@missionartistunited.org with no subject", function() {
      //   $(element)
      //     .find("a")
      //     .click();
      //   expect($window.location).toEqual("something ");
      // });
    });
  });
}.call(this));
