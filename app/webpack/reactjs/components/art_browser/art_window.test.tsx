import { ArtPiece } from "@models/art_piece.model";
import { jsonApiArtPieceFactory as artPieceFactory } from "@test/factories";
import { render, screen, waitFor} from "@testing-library/react";
import { api } from "@services/api";
import { mocked } from "ts-jest/utils";
import React from "react";

import { ArtWindow } from "./art_window";

jest.mock("@services/api");
const mockApi = mocked(api, true);


describe("ArtWindow", () => {
  let artPiece;
  beforeEach(() => {
    api.artPieces.image.mockResolvedValue({url:'https://theimage.whatever.com/thing.jpg'})
  });
  describe("if the art has sold", () => {
    beforeEach(() => {
      artPiece = new ArtPiece(artPieceFactory.build({ sold: undefined }));
    });
    it("matches the snapshot", async () => {
      const { container } = render(<ArtWindow art={artPiece} />);
      await waitFor (() => screen.getByText("Sold"))
      expect(container).toMatchSnapshot();
    });
  });

  describe("if the art has not sold", () => {
    beforeEach(() => {
      artPiece = new ArtPiece(artPieceFactory.build({ sold: new Date() }));
    });
    it("matches the snapshot", async () => {
      const { container } = render(<ArtWindow art={artPiece} />);
      await waitFor (() => screen.getByText("Sold"))
      expect(container).toMatchSnapshot();
    });
  });
});
