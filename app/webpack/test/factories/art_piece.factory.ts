import { identity } from "@js/app/typed_helpers";
import { ArtPiece } from "@models/art_piece.model";
import * as types from "@reactjs/types";
import { Factory } from "rosie";

const jsonApiArtPieceAttributesFactory =
  Factory.define<types.ArtPieceAttributes>("artPieceAttributes")
    .attr("artistName", "the artist name")
    .attr("favoritesCount", 0)
    .attr("price", "123")
    .attr("displayPrice", ["price"], (price: number) => `$${price}`)
    .attr("year", "2000")
    .attr("dimensions", "10x 20")
    .attr("title", "the title goes here")
    .attr("artistId", 45)
    .attr("imageUrls", {
      small: "small.png",
      medium: "medium.png",
      large: "large.png",
      original: "original.png",
    })
    .attr("soldAt", "a time stamp");

export const jsonApiArtPieceFactory = Factory.define<types.JsonApiArtPiece>(
  "jsonApiArtPiece"
)
  .sequence("id", identity)
  .attr("type", "art_piece")
  .attr("attributes", () => jsonApiArtPieceAttributesFactory.build())
  .attr("relationships", {});

export const artPieceFactory = {
  build: (attrs: Record<string, unknown>) => {
    const ap = new ArtPiece(jsonApiArtPieceFactory.build());
    Object.entries(attrs ?? {}).forEach((k, v) => {
      ap[k] = v;
    });
    return ap;
  },
};
