import { openStudiosParticipantFactory } from "@test/factories";
import { fireEvent, render, screen } from "@testing-library/react";
import expect from "expect";
import React from "react";

import { OpenStudiosRegistrationSection } from "./open_studios_registration_section";

jest.mock("@js/services/api");

describe("OpenStudiosRegistrationSection", () => {
  const defaultOsEvent = {
    dateRange: "The dates of the event",
  };
  const defaultProps = {
    participating: false,
    openStudiosEvent: defaultOsEvent,
    location: "The Location Is Here",
  };

  const renderComponent = (props = {}) => {
    const mergedProps = { ...defaultProps, ...props };
    render(<OpenStudiosRegistrationSection {...mergedProps} />);
  };

  beforeEach(() => {
    jest.resetAllMocks();
  });

  describe("when i'm participating", () => {
    beforeEach(() => {
      const participant = openStudiosParticipantFactory.build();
      renderComponent({ participant });
    });
    it("shows a message if you're already participating", () => {
      expect(
        screen.queryByText(
          "Yay! You are currently registered for Open Studios on The dates of the event",
          { exact: false }
        )
      ).toBeInTheDocument();
    });
  });

  describe("when i'm not yet participating", () => {
    beforeEach(() => {
      renderComponent({ participant: null });
    });
    it("shows a register button and message", () => {
      const button = screen.queryByRole("button", {
        name: "Yes - Register Me",
      });
      expect(button).toBeInTheDocument();
      expect(
        screen.queryByText("Will you be participating", { exact: false })
      ).toBeInTheDocument();
    });
    it("clicking the button opens a modal", () => {
      const button = screen.queryByRole("button", {
        name: "Yes - Register Me",
      });
      fireEvent.click(button);
      expect(
        screen.queryByText("Would you like to register", { exact: false })
      ).toBeInTheDocument();
    });
  });
});
