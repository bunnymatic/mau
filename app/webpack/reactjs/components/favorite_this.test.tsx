import { IdType } from "@reactjs/types";
import { api } from "@services/api";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import React from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { FavoriteThis } from "./favorite_this";

const mockWhoAmI = vi.spyOn(api.users, "whoami");
const mockAddFavorite = vi.spyOn(api.favorites, "add");

describe("FavoriteThis", () => {
  const renderComponent: (type?: string, id?: IdType) => void = (type, id) => {
    render(<FavoriteThis type={type} id={id} />);
  };

  describe("default", function () {
    beforeEach(() => {
      mockWhoAmI.mockResolvedValue({
        currentUser: { slug: "the-artist" },
      });
      mockAddFavorite.mockResolvedValue({});
    });

    it("sets up the directive with the art piece attributes", async function () {
      renderComponent("Artist", 10);
      const button = screen.queryByTitle("Add to your favorites");
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockWhoAmI).toHaveBeenCalled();
        expect(mockAddFavorite).toHaveBeenCalledWith(
          "the-artist",
          "Artist",
          10
        );
      });
    });
    it("calls the service with empties if there is no object or id", async function () {
      renderComponent();
      const button = screen.queryByTitle("Add to your favorites");
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockWhoAmI).toHaveBeenCalled();
        expect(mockAddFavorite).toHaveBeenCalledWith(
          "the-artist",
          "Artist",
          10
        );
      });
    });
  });

  describe("when you're not logged in", function () {
    beforeEach(() => {
      mockWhoAmI.mockResolvedValue({});
    });

    it("sets up the directive with the art piece attributes", async function () {
      renderComponent("Artist", 10);
      const button = screen.queryByTitle("Add to your favorites");
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockWhoAmI).toHaveBeenCalled();
        expect(
          screen.queryByText("You need to login", { exact: false })
        ).toBeInTheDocument();
      });
    });
  });

  describe("when the favorite call fails", function () {
    beforeEach(() => {
      mockWhoAmI.mockResolvedValue({
        currentUser: { slug: "the-artist" },
      });
      mockAddFavorite.mockRejectedValue({});
    });

    it("sets up the directive with the art piece attributes", async function () {
      renderComponent("Artist", 10);
      const button = screen.queryByTitle("Add to your favorites");
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockWhoAmI).toHaveBeenCalled();
        expect(
          screen.queryByText(
            "That item doesn't seem to be available to favorite",
            { exact: false }
          )
        ).toBeInTheDocument();
      });
    });
  });
});
