import { describe, expect, it } from "@jest/globals";
import { ArtPiece } from "@models/art_piece.model";
import { jsonApiArtPieceFactory } from "@test/factories";
import { render } from "@testing-library/react";
import { api } from "@services/api";
import { mocked } from "ts-jest/utils";

import React from "react";

import { ArtCard } from "./art_card";

jest.mock("@services/api");
const mockApi = mocked(api, true);


describe("ArtCard", () => {
  let artPiece;

  beforeEach(() => {
    api.artPieces.immge.mockResolvedValue('https://theimage.whatever.com/thing.jpg')
    artPiece = new ArtPiece(jsonApiArtPieceFactory.build());
  });

  it("matches the snapshot with all the props", () => {
    const { container } = render(<ArtCard artPiece={artPiece} />);
    expect(container).toMatchSnapshot();
  });

  it("matches the snapshot with minimal props", () => {
    artPiece.dimensions = undefined;
    artPiece.price = undefined;
    const { container } = render(<ArtCard artPiece={artPiece} />);
    expect(container).toMatchSnapshot();
  });
});
