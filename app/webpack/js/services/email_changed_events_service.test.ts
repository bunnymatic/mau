import { describe, expect, it } from "@jest/globals";
import { api } from "@services/api";
import { DateTime } from "luxon";
import { mocked } from "jest-mock";

import { EmailChangedEventsService } from "./email_changed_events.service";

jest.mock("@services/api");
const mockApi = mocked(api, true);

describe("EmailChangedEventsService", () => {
  describe("list", () => {
    beforeEach(() => {
      jest.resetAllMocks();
    });
    it("returns only events that are user changed events with email changes", async () => {
      const events = [
        { genericEvent: { id: 1, data: {}, message: "something" } },
        { userChangedEvent: { id: 2, data: {}, message: "something" } },
        {
          userChangedEvent: {
            id: 3,
            data: {
              changes: {
                nomdeplume: "old => new",
                email: "oldemail => newemail",
              },
              user: "atammara",
              user_id: 28,
            },
            message: "Catherin AAtammara updated nomdeplume, and email",
          },
        },
        {
          openStudiosSignupEvent: {
            id: 137,
            message: "whatever",
            data: { user: "the-login", user_id: 5 },
          },
        },
      ];
      mockApi.applicationEvents.index.mockResolvedValue({
        applicationEvents: events,
      });

      const result = await EmailChangedEventsService.list(DateTime.local());

      expect(result).toHaveLength(1);
      expect(result[0].userChangedEvent.id).toEqual(3);
    });
  });
});
