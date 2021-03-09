import { api } from "@js/services/api";
import { openStudiosParticipantFactory } from "@test/factories";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import expect from "expect";
import React from "react";

import { OpenStudiosRegistration } from "./open_studios_registration";

jest.mock("@js/services/api");

describe("OpenStudiosRegistration", () => {
  const defaultOsEvent = {
    dateRange: "The dates of the event",
  };
  const mockOnUpdate = jest.fn();
  const defaultProps = {
    autoRegister: false,
    openStudiosEvent: defaultOsEvent,
    location: "The Location Is Here",
    onUpdateParticipant: mockOnUpdate,
    artistId: 1,
  };

  const renderComponent = (props = {}) => {
    const mergedProps = { ...defaultProps, ...props };
    render(<OpenStudiosRegistration {...mergedProps} />);
  };

  beforeEach(() => {
    jest.resetAllMocks();
  });

  it("shows a register button", () => {
    renderComponent();
    const button = screen.queryByRole("button", { name: "Yes - Register Me" });
    expect(button).toBeInTheDocument();
  });

  it("if autoRegister is true, the modal starts open", () => {
    renderComponent({ autoRegister: true });
    expect(
      screen.queryByText(
        "Would you like to register as a participating artist?",
        { exact: false }
      )
    ).toBeInTheDocument();
  });

  describe("when I register", () => {
    const newParticipant = openStudiosParticipantFactory.build();
    beforeEach(() => {
      api.openStudios.submitRegistrationStatus.mockResolvedValue({
        participant: newParticipant,
      });
    });
    it("allows me to register", async () => {
      let yesButton;
      renderComponent();
      act(() => {
        const modalButton = screen.queryByRole("button", {
          name: "Yes - Register Me",
        });
        fireEvent.click(modalButton);
      });
      await waitFor(() => {
        yesButton = screen.queryByText("Yes");
        expect(yesButton).toBeInTheDocument();
      });
      act(() => {
        fireEvent.click(yesButton);
      });
      await waitFor(() => {
        expect(api.openStudios.submitRegistrationStatus).toHaveBeenCalledWith(
          true
        );
        expect(mockOnUpdate).toHaveBeenCalledWith(newParticipant);
      });
    });
  });
});
