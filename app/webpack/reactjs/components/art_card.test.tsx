import { describe, expect, it } from "@jest/globals";
import { ArtPiece } from "@models/art_piece.model";
import { api } from "@services/api";
import { jsonApiArtPieceFactory } from "@test/factories";
import { render, screen, waitFor } from "@testing-library/react";
import React from "react";
import { mocked } from "ts-jest/utils";

import { ArtCard } from "./art_card";

jest.mock("@services/api");
const mockApi = mocked(api, true);

describe("ArtCard", () => {
  let artPiece;

  beforeEach(() => {
    mockApi.artPieces.image.mockResolvedValue({
      url: "https://theimage.whatever.com/thing.jpg",
    });
    artPiece = new ArtPiece(jsonApiArtPieceFactory.build());
  });

  it("matches the snapshot with all the props", async () => {
    const { container } = render(<ArtCard artPiece={artPiece} />);
    await waitFor(() => {
      screen.getByText("Sold");
    });
    expect(container).toMatchSnapshot();
  });

  it("matches the snapshot with minimal props", async () => {
    artPiece.dimensions = undefined;
    artPiece.price = undefined;
    const { container } = render(<ArtCard artPiece={artPiece} />);
    await waitFor(() => {
      screen.getByText("Sold");
    });
    expect(container).toMatchSnapshot();
  });
});
