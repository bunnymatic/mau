import { describe, expect, it } from "@jest/globals";
import { api } from "@services/api";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import React from "react";
import { mocked } from "ts-jest/utils";

import { FavoriteThis } from "./favorite_this";

jest.mock("@services/api");

const mockApi = mocked(api, true);

describe("FavoriteThis", () => {
  const renderComponent = (type: string, id: number) => {
    render(<FavoriteThis type={type} id={id} />);
  };

  describe("default", function () {
    beforeEach(() => {
      mockApi.users.whoami.mockResolvedValue({
        currentUser: { slug: "the-artist" },
      });
      mockApi.favorites.add.mockResolvedValue({});
    });

    it("sets up the directive with the art piece attributes", async function () {
      renderComponent("Artist", 10);
      const button = screen.queryByTitle("Add to your favorites");
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockApi.users.whoami).toHaveBeenCalled();
        expect(mockApi.favorites.add).toHaveBeenCalledWith(
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
        expect(mockApi.users.whoami).toHaveBeenCalled();
        expect(mockApi.favorites.add).toHaveBeenCalledWith(
          "the-artist",
          "Artist",
          10
        );
      });
    });
  });

  describe("when you're not logged in", function () {
    beforeEach(() => {
      mockApi.users.whoami.mockResolvedValue({});
    });

    it("sets up the directive with the art piece attributes", async function () {
      renderComponent("Artist", 10);
      const button = screen.queryByTitle("Add to your favorites");
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockApi.users.whoami).toHaveBeenCalled();
        expect(
          screen.queryByText("You need to login", { exact: false })
        ).toBeInTheDocument();
      });
    });
  });

  describe("when the favorite call fails", function () {
    beforeEach(() => {
      mockApi.users.whoami.mockResolvedValue({
        currentUser: { slug: "the-artist" },
      });
      mockApi.favorites.add.mockRejectedValue({});
    });

    it("sets up the directive with the art piece attributes", async function () {
      renderComponent("Artist", 10);
      const button = screen.queryByTitle("Add to your favorites");
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockApi.users.whoami).toHaveBeenCalled();
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
