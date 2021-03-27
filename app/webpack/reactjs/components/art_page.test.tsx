import { describe, expect, it } from "@jest/globals";
import { ArtPiece } from "@models/art_piece.model";
import { jsonApi } from "@services/json_api";
import { jsonApiArtPieceFactory } from "@test/factories";
import { act, render, screen, waitFor } from "@testing-library/react";
import React from "react";
import { mocked } from "ts-jest/utils";

import { ArtPage } from "./art_page";

jest.mock("@services/json_api");

const mockApi = mocked(jsonApi, true);

describe("ArtPage", () => {
  const artistId = 4;

  beforeEach(() => {
    jest.resetAllMocks();
  });

  describe("when the art pieces fetch succeeds", () => {
    let artPieces: ArtPiece[];
    beforeEach(() => {
      artPieces = jsonApiArtPieceFactory
        .buildList(2)
        .map((artPiece) => new ArtPiece(artPiece));
      mockApi.artPieces.index.mockResolvedValue(artPieces);
    });

    it("renders the 2 art cards", async () => {
      act(() => {
        render(<ArtPage artistId={artistId} />);
      });
      await waitFor(() => {
        expect(
          screen.queryByText(artPieces[0].title, { exact: false })
        ).toBeInTheDocument();
        expect(
          screen.queryByText(artPieces[1].title, { exact: false })
        ).toBeInTheDocument();
      });
    });
  });

  describe("when the art pieces fetch fails", () => {
    beforeEach(() => {
      mockApi.artPieces.index.mockRejectedValue({});
      render(<ArtPage artistId={artistId} />);
    });

    it("renders a flash", () => {
      expect(screen.queryByText("Ack!", { exact: false })).toBeInTheDocument();
    });
  });
});
