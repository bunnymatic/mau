import { describe, expect, it, jest } from "@jest/globals";
import { noop } from "@js/app/helpers";
import { jsonApi } from "@js/services/json_api";
import { ArtPiece } from "@models/art_piece.model";
import { jsonApiArtPieceFactory } from "@test/factories";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import React from "react";
import { mocked } from "ts-jest/utils";

import { ArtModal } from "./art_modal";

jest.mock("@js/services/json_api");

const mockApi = mocked(jsonApi, true);

describe("ArtModal", () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });
  const renderComponent = (props) => {
    return render(
      <ArtModal id={5} {...props}>
        <button data-testid="trigger">trigger open</button>
      </ArtModal>
    );
  };

  it("renders the trigger", async () => {
    act(() => {
      renderComponent();
    });
    await waitFor(() => {
      expect(screen.getByTestId("trigger")).toBeInTheDocument();
    });
  });

  describe("when the art piece is available", () => {
    let artPiece;

    beforeEach(() => {
      artPiece = new ArtPiece(jsonApiArtPieceFactory.build());
      mockApi.artPieces.get.mockResolvedValue(artPiece);
    });

    describe("when you click the trigger", () => {
      it("clicking the trigger fetches art piece data", async () => {
        act(() => {
          renderComponent();
        });
        await waitFor(noop);

        act(() => {
          const button = screen.getByTestId("trigger");
          fireEvent.click(button);
        });
        await waitFor(() => {
          expect(mockApi.artPieces.get).toHaveBeenCalledWith(5);
        });
      });

      it("clicking the trigger shows the modal window", async () => {
        renderComponent();
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
  });

  describe("when the art piece fetch fails", () => {
    beforeEach(() => {
      mockApi.artPieces.get.mockRejectedValue({});
    });

    describe("when you click the trigger", () => {
      it("renders a flash", async () => {
        act(() => {
          renderComponent();
        });
        act(() => {
          const button = screen.getByTestId("trigger");
          fireEvent.click(button);
        });
        await waitFor(() => {
          expect(
            screen.queryByText("We are having some issues getting that art", {
              exact: false,
            })
          ).toBeInTheDocument();
        });
      });
    });
  });
});
