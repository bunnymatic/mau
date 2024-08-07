import { ArtPiece } from "@models/art_piece.model";
import { Artist } from "@models/artist.model";
import { Studio } from "@models/studio.model";
import jQuery from "jquery";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { jsonApi } from "./json_api";

vi.mock("@models/artist.model");
vi.mock("@models/art_piece.model");
vi.mock("@models/studio.model");

const MOCK_JSON_API_GET_RESPONSE = {
  data: { data_that: "gets camelized" },
  included: { other_stuff_that: "gets camelized" },
};

describe("jsonApi", () => {
  beforeEach(() => {
    vi.resetAllMocks();
    vi.spyOn(jQuery, "ajaxSetup");
  });
  describe("artists", () => {
    describe("get", () => {
      beforeEach(() => {
        vi.spyOn(jQuery, "ajax").mockResolvedValue(MOCK_JSON_API_GET_RESPONSE);
      });
      it("returns builds an artist model with the json api data", async () => {
        await jsonApi.artists.get(5);
        expect(Artist).toHaveBeenCalledWith(
          { dataThat: "gets camelized" },
          { otherStuffThat: "gets camelized" }
        );
      });
      it("calls the api endpoint", async () => {
        await jsonApi.artists.get(5);
        expect(jQuery.ajax).toHaveBeenCalledWith(
          expect.objectContaining({
            url: "/api/v2/artists/5.json",
            method: "get",
          })
        );
      });
    });
  });
  describe("artPieces", () => {
    describe("get", () => {
      beforeEach(() => {
        vi.spyOn(jQuery, "ajax").mockResolvedValue(MOCK_JSON_API_GET_RESPONSE);
      });
      it("returns builds an art piece model with the json api data", async () => {
        await jsonApi.artPieces.get(5);
        expect(ArtPiece).toHaveBeenCalledWith(
          { dataThat: "gets camelized" },
          { otherStuffThat: "gets camelized" }
        );
      });
      it("calls the api endpoint", async () => {
        await jsonApi.artPieces.get(5);
        expect(jQuery.ajax).toHaveBeenCalledWith(
          expect.objectContaining({
            url: "/api/v2/art_pieces/5.json",
            method: "get",
          })
        );
      });
    });
    describe("index", () => {
      beforeEach(() => {
        vi.spyOn(jQuery, "ajax").mockResolvedValue({
          data: [{ art_piece: 1 }, { art_piece: 2 }],
          included: { other_stuff_that: "gets camelized" },
        });
      });
      it("returns builds an art piece model with the json api data", async () => {
        await jsonApi.artPieces.index(55);
        expect(ArtPiece).toHaveBeenCalledWith(
          { artPiece: 1 },
          { otherStuffThat: "gets camelized" }
        );
        expect(ArtPiece).toHaveBeenCalledWith(
          { artPiece: 2 },
          { otherStuffThat: "gets camelized" }
        );
      });
      it("calls the api endpoint", async () => {
        await jsonApi.artPieces.index(54);
        expect(jQuery.ajax).toHaveBeenCalledWith(
          expect.objectContaining({
            url: "/api/v2/artists/54/art_pieces.json",
            method: "get",
          })
        );
      });
    });
  });
  describe("studio", () => {
    describe("get", () => {
      beforeEach(() => {
        vi.spyOn(jQuery, "ajax").mockResolvedValue(MOCK_JSON_API_GET_RESPONSE);
      });
      it("returns builds an studio model with the json api data", async () => {
        await jsonApi.studios.get(5);
        expect(Studio).toHaveBeenCalledWith(
          { dataThat: "gets camelized" },
          { otherStuffThat: "gets camelized" }
        );
      });
      it("calls the api endpoint", async () => {
        await jsonApi.studios.get(5);
        expect(jQuery.ajax).toHaveBeenCalledWith(
          expect.objectContaining({
            url: "/api/v2/studios/5.json",
            method: "get",
          })
        );
      });
      it("calls for studio 0 if the value is null", async () => {
        await jsonApi.studios.get(null);
        expect(jQuery.ajax).toHaveBeenCalledWith(
          expect.objectContaining({
            url: "/api/v2/studios/0.json",
            method: "get",
          })
        );
      });
      it("calls for studio 0 if the value is undefined", async () => {
        await jsonApi.studios.get();
        expect(jQuery.ajax).toHaveBeenCalledWith(
          expect.objectContaining({
            url: "/api/v2/studios/0.json",
            method: "get",
          })
        );
      });
    });
  });
});
