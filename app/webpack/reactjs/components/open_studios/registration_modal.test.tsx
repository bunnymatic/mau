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

import { RegistrationModal } from "./registration_modal";

jest.mock("@js/services/api");

describe("RegistrationModal", () => {
  const defaultOsEvent = {
    dateRange: "The dates of the event",
  };
  const mockOnUpdate = jest.fn();
  const defaultProps = {
    openStudiosEvent: defaultOsEvent,
    location: "The Location Is Here",
    onUpdateParticipant: mockOnUpdate,
    artistId: 1,
    buttonText: "Click Me!",
  };

  const renderComponent = (props = {}) => {
    const mergedProps = { ...defaultProps, ...props };
    render(<RegistrationModal {...mergedProps} />);
  };

  beforeEach(() => {
    jest.resetAllMocks();
  });

  it("shows a register button", () => {
    renderComponent();
    const button = screen.queryByRole("button", { name: "Click Me!" });
    expect(button).toBeInTheDocument();
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
          name: "Click Me!",
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
