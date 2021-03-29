import { ArtPiece } from "@models/art_piece.model";
import { jsonApiArtPieceFactory as artPieceFactory } from "@test/factories";
import { render } from "@testing-library/react";
import React from "react";

import { ArtWindow } from "./art_window";

describe("ArtWindow", () => {
  let artPiece;
  describe("if the art has sold", () => {
    beforeEach(() => {
      artPiece = new ArtPiece(artPieceFactory.build({ sold: undefined }));
    });
    it("matches the snapshot", () => {
      const { container } = render(<ArtWindow art={artPiece} />);
      expect(container).toMatchSnapshot();
    });
  });

  describe("if the art has not sold", () => {
    beforeEach(() => {
      artPiece = new ArtPiece(artPieceFactory.build({ sold: new Date() }));
    });
    it("matches the snapshot", () => {
      const { container } = render(<ArtWindow art={artPiece} />);
      expect(container).toMatchSnapshot();
    });
  });
});
