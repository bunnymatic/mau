import { ArtPiece } from "@models/art_piece.model";
import { jsonApiArtPieceFactory as artPieceFactory } from "@test/factories";
import { render } from "@testing-library/react";
import React from "react";

import { ArtWindow } from "./art_window";

describe("ArtWindow", () => {
  let artPiece;
  beforeEach(() => {
    artPiece = new ArtPiece(artPieceFactory.build());
  });
  it("matches the snapshot", () => {
    const { container } = render(<ArtWindow art={artPiece} />);
    expect(container).toMatchSnapshot();
  });
});
