import "angular-mocks";
import "./search_hit";
import "@services/object_routing.service";

import esSearchResults from "@fixtures/files/search_results.json";
import angular from "angular";
import expect from "expect";

describe("mau.models.SearchHit", function () {
  let model;

  beforeEach(angular.mock.module("mau.models"));
  beforeEach(angular.mock.module("mau.services"));

  const SAMPLE_ARTIST_ES_HIT = esSearchResults.hits.hits[0];
  const SAMPLE_STUDIO_ES_HIT = esSearchResults.hits.hits[1];
  const SAMPLE_ART_PIECE_ES_HIT = esSearchResults.hits.hits[2];

  beforeEach(angular.mock.inject((SearchHit) => (model = SearchHit)));

  it("translates a studio ES result into a search hit", () => {
    const esHit = SAMPLE_STUDIO_ES_HIT;
    const hit = new model(esHit);
    expect(hit.type).toEqual("studio");
    expect(hit.iconClass).toContain("fa-building");
    expect(hit.link).toEqual(`/studios/${esHit._source.studio.slug}`);
    expect(hit.name).toEqual(esHit._source.studio.name);
    expect(Object.keys(hit).sort()).toEqual([
      "description",
      "hit",
      "iconClass",
      "id",
      "image",
      "link",
      "name",
      "osParticipant",
      "score",
      "type",
    ]);
  });
  it("translates a artist ES result into a search hit", () => {
    const esHit = SAMPLE_ARTIST_ES_HIT;
    const hit = new model(esHit);
    expect(hit.type).toEqual("artist");
    expect(hit.iconClass).toContain("fa-user");
    expect(hit.link).toEqual(`/artists/${esHit._source.artist.slug}`);
    expect(hit.name).toEqual(esHit._source.artist.artist_name);
    expect(Object.keys(hit).sort()).toEqual([
      "description",
      "hit",
      "iconClass",
      "id",
      "image",
      "link",
      "name",
      "osParticipant",
      "score",
      "type",
    ]);
  });
  it("translates a art piece ES result into a search hit", () => {
    const esHit = SAMPLE_ART_PIECE_ES_HIT;
    const hit = new model(esHit);
    expect(hit.type).toEqual("art_piece");
    expect(hit.iconClass).toContain("fa-image");
    expect(hit.link).toEqual(`/art_pieces/${esHit._source.art_piece.id}`);
    expect(hit.name).toContain(esHit._source.art_piece.title);
    expect(hit.name).toContain("<span class='byline-conjunction'>by</span>");
    expect(hit.name).toContain(
      `<span class='artist-name'>${esHit._source.art_piece.artist_name}</span>`
    );
    expect(Object.keys(hit).sort()).toEqual([
      "hit",
      "iconClass",
      "id",
      "image",
      "link",
      "medium",
      "name",
      "osParticipant",
      "score",
      "tags",
      "type",
    ]);
  });
});
