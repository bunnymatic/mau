import "angular-mocks";
import "./art_pieces.service";

import angular from "angular";
import expect from "expect";

describe("mau.services.artPiecesService", function () {
  let service, http;

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function ($httpBackend, artPiecesService) {
      service = artPiecesService;
      http = $httpBackend;
    })
  );
  afterEach(function () {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });
  describe(".get", function () {
    it("calls the artPieces api endpoint", function () {
      const artPiece = { id: 10, title: "Artperson" };
      http.expectGET(`/api/v2/art_pieces/${artPiece.id}.json`).respond({
        art_piece: artPiece,
      });
      const response = service.get(artPiece.id);
      http.flush();
      response.$promise.then(function (data) {
        expect(data.toJSON()).toEqual(artPiece);
      });
    });
  });

  describe(".list", function () {
    it("calls the artists/art_pieces api endpoint", function () {
      const artist = { id: 4, first_name: "Leonardo" };
      const artPieces = [{ id: 10, title: "Artperson" }];
      http.expectGET(`/api/v2/artists/${artist.id}/art_pieces.json`).respond({
        art_pieces: artPieces,
      });
      const response = service.list(artist.id);
      http.flush();
      response.$promise.then(function (data) {
        expect(data.map((d) => d.toJSON())).toEqual(artPieces);
      });
    });
  });
});
