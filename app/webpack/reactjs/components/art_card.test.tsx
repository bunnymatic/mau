import { describe, expect, it } from "@jest/globals";
import { ArtPiece } from "@models/art_piece.model";
import { jsonApiArtPieceFactory } from "@test/factories";
import { render } from "@testing-library/react";
import React from "react";

import { ArtCard } from "./art_card";

describe("ArtCard", () => {
  let artPiece;

  beforeEach(() => {
    artPiece = new ArtPiece(jsonApiArtPieceFactory.build());
  });

  it("matches the snapshot with all the props", () => {
    const { container } = render(<ArtCard artPiece={artPiece} />);
    expect(container).toMatchSnapshot();
  });

  it("matches the snapshot with minimal props", () => {
    const { id, title, imageUrls } = artPiece;
    const trimArtPiece = { id, title, imageUrls };
    const { container } = render(<ArtCard artPiece={trimArtPiece} />);
    expect(container).toMatchSnapshot();
  });
});
