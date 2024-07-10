import {
  openStudiosEventFactory,
  openStudiosParticipantFactory,
} from "@test/factories";
import { fireEvent, render, screen } from "@testing-library/react";
import React from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { OpenStudiosRegistrationSection } from "./open_studios_registration_section";

vi.mock("@services/api");

describe("OpenStudiosRegistrationSection", () => {
  const defaultOsEvent = openStudiosEventFactory.build();
  const defaultProps = {
    participant: null,
    openStudiosEvent: defaultOsEvent,
    location: "The Location Is Here",
    artistId: 5,
  };

  const renderComponent = (props = {}) => {
    const mergedProps = { ...defaultProps, ...props };
    render(<OpenStudiosRegistrationSection {...mergedProps} />);
  };

  beforeEach(() => {});

  describe("when i'm participating", () => {
    beforeEach(() => {
      const participant = openStudiosParticipantFactory.build();
      renderComponent({ participant });
    });
    it("shows a message if you're already participating", () => {
      expect(
        screen.queryByText(
          "Yay! You are currently registered for Open Studios on July 10-12 2020",
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
        screen.queryByText("Would you like to continue", { exact: false })
      ).toBeInTheDocument();
    });
  });
});
