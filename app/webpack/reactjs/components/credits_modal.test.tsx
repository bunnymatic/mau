import { fireEvent, render, screen } from "@testing-library/react";
import React from "react";
import { describe, expect, it, vi } from "vitest";

import { CreditsWindow } from "./credits_modal";

describe("CreditsModal", () => {
  const handleClose = vi.fn();
  describe("CreditsWindow", () => {
    it("renders the credits window", () => {
      render(
        <CreditsWindow
          handleClose={handleClose}
          version="1.0 version goes here"
        />
      );
      expect(screen.getByText("Credits")).toBeInTheDocument();
      expect(screen.getByRole("link", { name: "Mr Rogers" })).toHaveAttribute(
        "href",
        "http://rcode5.com"
      );
      expect(
        screen.getByRole("link", { name: "Trish Tunney" })
      ).toHaveAttribute("href", "http://trishtunney.com");

      expect(
        screen.getByText("Liwei Xu", { exact: false })
      ).toBeInTheDocument();
      expect(
        screen.getByText("Ryan Workman", { exact: false })
      ).toBeInTheDocument();
      expect(
        screen.getByText("Kathrin Neyzberg", { exact: false })
      ).toBeInTheDocument();
      expect(
        screen.queryByText("Version: 1.0 version goes here")
      ).toBeInTheDocument();
    });

    it("calls handleClose when close is clicked", () => {
      render(
        <CreditsWindow
          handleClose={handleClose}
          version="1.0 version goes here"
        />
      );
      const closeButton = screen.queryByTitle("close");
      fireEvent.click(closeButton);
      expect(handleClose).toHaveBeenCalled();
    });
  });
});
