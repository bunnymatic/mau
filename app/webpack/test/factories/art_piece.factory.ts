import { identity } from "@js/app/helpers";
import * as types from "@reactjs/types";
import { randomInt } from "@test/support/faker_helpers";
import { lorem } from "faker";
import { Factory } from "rosie";

const jsonApiArtPieceAttributesFactory = Factory.define<types.ArtPieceAttributes>(
  "artPieceAttributes"
)
  .attr("artistName", "the artist name")
  .attr("favoritesCount", 0)
  .attr("price", () => randomInt(100, 10000))
  .attr("displayPrice", ["price"], (price: number) => `$${price}`)
  .attr("year", () => randomInt(2020, 1940))
  .attr("dimensions", "10x 20")
  .attr("title", () => `the title of the piece ${lorem.words(4)}`)
  .attr("artistId", 45)
  .attr("imageUrls", {
    small: "small.png",
    medium: "medium.png",
    large: "large.png",
    original: "original.png",
  })
  .attr("sold_at", "a time stamp");

export const jsonApiArtPieceFactory = Factory.define<types.JsonApiArtPiece>(
  "jsonApiArtPiece"
)
  .sequence("id", identity)
  .attr("type", "art_piece")
  .attr("attributes", () => jsonApiArtPieceAttributesFactory.build())
  .attr("relationships", {});
