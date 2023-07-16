import { describe, expect, it, jest } from "@jest/globals";
import { ArtPiece } from "@models/art_piece.model";
import { jsonApiArtPieceFactory } from "@test/factories";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import { api } from "@services/api";
import { mocked } from "ts-jest/utils";
import React from "react";

import { ArtModal } from "./art_modal";

jest.mock("@services/api");
const mockApi = mocked(api, true);

describe("ArtModal", () => {
  beforeEach(() => {
    api.artPieces.image.mockResolvedValue({url:'https://theimage.whatever.com/thing.jpg'})
    jest.resetAllMocks();
  });

  const renderComponent = (props) => {
    return render(
      <ArtModal {...props}>
        <button data-testid="trigger">trigger open</button>
      </ArtModal>
    );
  };

  it("renders the trigger", async () => {
    renderComponent();
    expect(screen.getByTestId("trigger")).toBeInTheDocument();
  });

  describe("when the art piece is available", () => {
    let artPiece;

    beforeEach(() => {
      artPiece = new ArtPiece(jsonApiArtPieceFactory.build());
    });

    it("clicking the trigger shows the modal window", async () => {
      renderComponent({ artPiece });
      const button = screen.getByTestId("trigger");

      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(screen.queryByText(artPiece.title)).toBeInTheDocument();
        expect(screen.queryByText(artPiece.dimensions)).toBeInTheDocument();
        expect(screen.queryByText(artPiece.displayPrice)).toBeInTheDocument();
      });
    });
  });

  describe("when there is no art", () => {
    it("renders nothing", async () => {
      const { container } = renderComponent();
      expect(container).toMatchSnapshot();
    });
  });
});
