import { describe, expect, it } from "@jest/globals";
import { ArtPiece } from "@models/art_piece.model";
import { jsonApiArtPieceFactory } from "@test/factories";
import { fireEvent, render, screen } from "@testing-library/react";
import React from "react";

import { ArtCard } from "./art_card";

describe("ArtCard", () => {
  let artPiece;

  beforeEach(() => {
    artPiece = new ArtPiece(jsonApiArtPieceFactory.build());
  });

  it("matches the snapshot with all the props", () => {
    const {
      id,
      title,
      sold,
      price,
      dimensions,
      year,
      imageUrls: images,
    } = artPiece;
    const props = { id, title, sold, price, dimensions, year, images };
    const { container } = render(<ArtCard {...props} />);
    expect(container).toMatchSnapshot();
  });

  it("matches the snapshot with minimal props", () => {
    const { id, title, imageUrls: images } = artPiece;
    const props = { id, title, images };
    const { container } = render(<ArtCard {...props} />);
    expect(container).toMatchSnapshot();
  });

  it("clicking the card opens the modal", () => {
    const { id, title, imageUrls: images } = artPiece;
    const props = { id, title, images };
    render(<ArtCard {...props} />);
    const trigger = screen.queryByText(title, { exact: false });
    fireEvent.click(trigger);
    expect(
      screen.queryByRole("progressbar", { hidden: true })
    ).toBeInTheDocument();
  });
});
