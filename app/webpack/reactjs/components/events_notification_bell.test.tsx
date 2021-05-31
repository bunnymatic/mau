import { describe, expect, it } from "@jest/globals";
import { EmailChangedEventsService } from "@js/services/email_changed_events.service";
import { act, render, screen, waitFor } from "@testing-library/react";
import React from "react";
import { mocked } from "ts-jest/utils";

import { EventsNotificationBell } from "./events_notification_bell";

jest.mock("@js/services/email_changed_events.service");
const mockService = mocked(EmailChangedEventsService, true);

class EventsNotificationBellPageObject {
  constructor() {
    jest.resetAllMocks();
  }

  render() {
    return render(<EventsNotificationBell />);
  }

  setupApiMocks(found = true) {
    const data = found
      ? [{ userChangedEvent: { data: { stuff: "here" } } }]
      : [];
    mockService.list.mockResolvedValue(data);
  }
}

describe("EventsNotificationBell", () => {
  let po: EventsNotificationBellPageObject;

  beforeEach(() => {
    po = new EventsNotificationBellPageObject();
  });

  describe("when there are events that should trigger a notification", () => {
    beforeEach(() => {
      po.setupApiMocks();
    });
    it("renders a bell", async () => {
      act(() => {
        po.render();
      });
      await waitFor(() => {
        expect(screen.getByTitle("Something happened!")).toBeInTheDocument();
      });
    });
  });

  describe("when there are events that should trigger a notification", () => {
    beforeEach(() => {
      po.setupApiMocks(false);
    });
    it("renders nothing", async () => {
      let container;
      act(() => {
        const rendered = po.render();
        container = rendered.container;
      });
      await waitFor(() => {
        expect(container).toBeEmptyDOMElement();
      });
    });
  });
});
