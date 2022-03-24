import { describe, expect, it } from "@jest/globals";
import { api } from "@js/services/api";

import * as notificationService from "./notification.service";

jest.mock("@services/api");

describe("mau.services.notificationService", function () {
  beforeEach(() => {
    jest.resetAllMocks();
  });
  const successPayload = { success: true };

  describe(".sendInquiry", function () {
    it("calls the note create endpoint", async function () {
      api.notes.create = jest.fn().mockResolvedValue(successPayload);
      const noteInfo = {
        noteType: "inquiry",
        inquiry: "what's up?",
        email: "jon@example.com",
      };
      const response = await notificationService.sendInquiry(noteInfo);
      expect(api.notes.create).toHaveBeenCalledWith({
        feedback_mail: expect.objectContaining({
          browser: { name: "Safari" },
          email: "jon@example.com",
          engine: { name: "Blink" },
          noteType: "inquiry",
          question: "what's up?",
        }),
      });
      expect(response).toEqual(successPayload);
    });
  });
});
