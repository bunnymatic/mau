import * as types from "@reactjs/types";
import { Factory } from "rosie";

const jsonApiArtPieceAttributesFactory = Factory.define<types.ArtPieceAttributes>(
  "artPieceAttributes"
)
  .attr("artistName", "the artist name")
  .attr("favoritesCount", 0)
  .attr("price", 123)
  .attr("displayPrice", "$123.00")
  .attr("year", "1234")
  .attr("dimensions", "10x 20")
  .attr("title", "the title of the piece")
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
  .attr("id", 5)
  .attr("type", "art_piece")
  .attr("attributes", () => jsonApiArtPieceAttributesFactory.build())
  .attr("relationships", {});
