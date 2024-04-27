import { ArtPiece } from "@models/art_piece.model";
import { jsonApi } from "@services/json_api";
import { jsonApiArtPieceFactory } from "@test/factories";
import { act, render, screen, waitFor } from "@testing-library/react";
import React from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { ArtPage } from "./art_page";

describe("ArtPage", () => {
  const artistId = 4;
  const mockArtPiecesIndex = vi.fn();

  beforeEach(() => {
    vi.resetAllMocks();
    vi.spyOn(jsonApi.artPieces, "index").mockImplementation(mockArtPiecesIndex);
  });

  describe("when the art pieces fetch succeeds", () => {
    let artPieces: ArtPiece[];
    beforeEach(() => {
      artPieces = jsonApiArtPieceFactory
        .buildList(2)
        .map((artPiece) => new ArtPiece(artPiece));
      mockArtPiecesIndex.mockResolvedValue(artPieces);
    });

    it("renders the 2 art cards", async () => {
      act(() => {
        render(<ArtPage artistId={artistId} />);
      });
      await waitFor(() => {
        // building a factory with random values busts the snapshot
        // testing so here all pieces have the same title
        expect(
          screen.queryAllByText(artPieces[0].dimensions, { exact: false })
        ).toHaveLength(2);
      });
    });
  });

  describe("when the art pieces fetch fails", () => {
    beforeEach(() => {
      mockArtPiecesIndex.mockRejectedValue({});
    });

    it("renders a flash", async () => {
      render(<ArtPage artistId={artistId} />);
      await waitFor(() => {
        expect(
          screen.queryByText("Ack!", { exact: false })
        ).toBeInTheDocument();
      });
    });
  });
});
