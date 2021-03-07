import { OpenStudiosInfoForm } from "./open_studios_info_form";
import {
  openStudiosEventFactory,
  openStudiosParticipantFactory,
} from "@test/factories";
import { api } from "@js/services/api";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import { findButton, findField, fillIn } from "@test/support/dom_finders";
import expect from "expect";
import React from "react";

jest.mock("@js/services/api");

describe("OpenStudiosInfoForm", () => {
  const defaultOsEvent = openStudiosEventFactory.build();
  const participant = openStudiosParticipantFactory.build();
  const mockOnUpdateParticipant = jest.fn();
  const artistId = 4;
  const defaultProps = {
    location: "the place",
    artistId,
    participant,
    openStudiosEvent: defaultOsEvent,
    onUpdateParticipant: mockOnUpdateParticipant,
  };

  const renderComponent = (props = {}) => {
    const mergedProps = { ...defaultProps, ...props };
    render(<OpenStudiosInfoForm {...mergedProps} />);
  };

  const mockUpdate = api.openStudios.participants.update;
  const mockSubmitRegStatus = api.openStudios.submitRegistrationStatus;

  describe("without interaction", () => {
    describe("when there is no special event", () => {
      beforeEach(() => {
        mockUpdate.mockResolvedValue({});
        renderComponent();
      });

      it("shows instructions", () => {
        expect(
          screen.queryByText("You pick how you want to participate", {
            exact: false,
          })
        ).toBeInTheDocument();
      });

      it("shows 2 dates for the event in fields *and* in the instructions", () => {
        const dateRanges = screen.queryAllByText(defaultOsEvent.dateRange, {
          exact: false,
        });

        expect(dateRanges).toHaveLength(3);
      });

      it("shows a form", () => {
        expect(findField("Shopping Cart Link")).toBeInTheDocument();
        expect(findField("Meeting Link (Zoom or other)")).toBeInTheDocument();
        expect(findField("Youtube Video Link")).toBeInTheDocument();
        expect(findField("Show my e-mail")).toBeInTheDocument();
        expect(findField("Show my phone number")).toBeInTheDocument();
        expect(findButton("Update my details")).toBeInTheDocument();
        expect(findButton("Un-Register Me")).toBeInTheDocument();
      });
    });

    describe("when there is a special event", () => {
      beforeEach(() => {
        const openStudiosEvent = openStudiosEventFactory.build({
          specialEvent: {
            dateRange: "some other dates that are important",
          },
        });
        mockUpdate.mockResolvedValue({});
        renderComponent({ openStudiosEvent });
      });

      it("shows instructions with the special event date range", () => {
        expect(
          screen.queryByText("You pick how you want to participate", {
            exact: false,
          })
        ).toBeInTheDocument();
        expect(
          screen.queryByText("some other dates that are important", {
            exact: false,
          })
        ).toBeInTheDocument();
      });

      it("shows main dates for the events in 2 fields", () => {
        const dateRanges = screen.queryAllByText(defaultOsEvent.dateRange, {
          exact: false,
        });

        expect(dateRanges).toHaveLength(2);
      });
    });
  });

  describe("when the update call succeeds", () => {
    beforeEach(() => {
      jest.resetAllMocks();
      mockUpdate.mockResolvedValue({
        openStudiosParticipant: participant,
      });
      renderComponent();
    });
    it("updates my info when i fill in the form and save", async () => {
      let button;
      act(() => {
        const shopUrl = findField("Shopping Cart Link");
        fillIn(shopUrl, "http://www.whatever.com");

        const youtubeUrl = findField("Youtube Video Link");
        fillIn(youtubeUrl, "http://www.youtube.com/watch?v=the-video");
      });
      await waitFor(() => {
        button = findButton("Update my details");
        expect(button).not.toBeDisabled();
      });
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockUpdate).toHaveBeenCalledWith({
          artistId,
          id: participant.id,
          openStudiosParticipant: {
            ...participant,
            shopUrl: "http://www.whatever.com",
            youtubeUrl: "http://www.youtube.com/watch?v=the-video",
          },
        });
        expect(mockOnUpdateParticipant).toHaveBeenCalledWith(participant);

        expect(screen.queryByText("Super. Got it!")).toBeInTheDocument();
      });
    });
  });

  describe("when the form submit fails", () => {
    beforeEach(() => {
      jest.resetAllMocks();
      mockUpdate.mockRejectedValue({
        responseJSON: {
          errors: {
            shopUrl: ["is wrong"],
          },
        },
      });
      renderComponent();
    });
    it("tells me when i make a mistake while filling out the form and saving", async () => {
      let button;
      act(() => {
        const shopUrl = findField("Shopping Cart Link");
        fillIn(shopUrl, "blah");
      });
      await waitFor(() => {
        button = findButton("Update my details");
        expect(button).not.toBeDisabled();
      });
      act(() => {
        fireEvent.click(button);
      });
      await waitFor(() => {
        expect(mockUpdate).toHaveBeenCalledWith({
          artistId,
          id: participant.id,
          openStudiosParticipant: { ...participant, shopUrl: "blah" },
        });
        expect(
          screen.queryByText("Whoops. There was a problem.")
        ).toBeInTheDocument();
      });
    });
  });

  describe("if i change my mind", () => {
    beforeEach(() => {
      jest.resetAllMocks();
      mockSubmitRegStatus.mockResolvedValue({});
      renderComponent();
    });
    it("triggers a cancel when i click the cancel button", async () => {
      let cancelButton;
      act(() => {
        cancelButton = findButton("Un-Register Me");
        fireEvent.click(cancelButton);
      });
      await waitFor(() => {
        expect(mockSubmitRegStatus).toHaveBeenCalledWith(false);
        expect(mockOnUpdateParticipant).toHaveBeenCalledWith(null);
      });
    });
  });
});
