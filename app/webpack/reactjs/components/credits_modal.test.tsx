import { fireEvent, render, screen } from "@testing-library/react";
import React from "react";

import { CreditsWindow } from "./credits_modal";

describe("CreditsModal", () => {
  const handleClose = jest.fn();
  beforeEach(() => {
    jest.resetAllMocks();
  });
  describe("CreditsWindow", () => {
    it("renders the credits window", () => {
      render(
        <CreditsWindow
          handleClose={handleClose}
          version="1.0 version goes here"
        />
      );
      expect(screen.queryByText("Credits")).toBeInTheDocument();
      const trish = screen.queryByText("Trish Tunney", { exact: false });
      const mrRogers = screen.queryByText("Mr Rogers", { exact: false });
      const liwei = screen.queryByText("Liwei Xu", { exact: false });
      const ryan = screen.queryByText("Ryan Workman", { exact: false });
      expect(ryan).toBeInTheDocument();
      expect(liwei).toBeInTheDocument();
      expect(trish).toBeInTheDocument();
      expect(mrRogers).toBeInTheDocument();
      expect(mrRogers.closest("a").href).toEqual("http://rcode5.com/");
      expect(trish.closest("a").href).toEqual("http://trishtunney.com/");
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
