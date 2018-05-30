/*eslint no-unused-vars: "off"*/

(function() {
  describe("mau.directives.favoriteThis", function($q) {
    var artPieceTemplate, artistTemplate, blankTemplate;
    artistTemplate =
      "<favorite-this object-type='Artist', object-id='3'></favorite-this>";
    artPieceTemplate =
      "<favorite-this object-type='ArtPiece' object-id='2'></favorite-this>";
    blankTemplate = "<favorite-this></favorite-this>";
    beforeEach(module("mau.directives"));
    beforeEach(module("templates"));
    beforeEach(module("mau.services"));
    beforeEach(function() {
      return inject(function($q, currentUserService, favoritesService) {
        this.favoritesService = favoritesService;
        spyOn(currentUserService, "get").and.callFake(function() {
          return $q.when(
            {
              current_user: "bmatic"
            },
            {
              current_user: null
            }
          );
        });
        return spyOn(this.favoritesService, "add").and.callFake(function() {
          var error, success;
          success = {
            artist: {
              id: "artistid"
            }
          };
          error = {};
          return $q.when(success, error);
        });
      });
    });
    return describe("with an art piece", function() {
      var scope;
      scope = {};
      it("sets up the directive with the art piece attributes", function() {
        var args, e;
        e = compileTemplate(artistTemplate, scope);
        $(e)
          .find("a")
          .click();
        expect(this.favoritesService.add).toHaveBeenCalled();
        args = this.favoritesService.add.calls.mostRecent().args;
        return expect(args).toEqual(["Artist", "3"]);
      });
      it("submits a request to favorite that art piece when clicked on", function() {
        var args, e;
        e = compileTemplate(artPieceTemplate, scope);
        $(e)
          .find("a")
          .click();
        expect(this.favoritesService.add).toHaveBeenCalled();
        args = this.favoritesService.add.calls.mostRecent().args;
        return expect(args).toEqual(["ArtPiece", "2"]);
      });
      return it("calls the service with empties if there is no object or id", function() {
        var args, e;
        e = compileTemplate(blankTemplate, scope);
        $(e)
          .find("a")
          .click();
        expect(this.favoritesService.add).toHaveBeenCalled();
        args = this.favoritesService.add.calls.mostRecent().args;
        return expect(args).toEqual([void 0, void 0]);
      });
    });
  });
}.call(this));
