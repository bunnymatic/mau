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
    it("calls the note create endpoint", function () {
      api.notes.create = jest.fn().mockResolvedValue(successPayload);
      const noteInfo = {
        noteType: "inquiry",
        question: "what's up?",
        email: "jon@example.com",
      };
      const response = notificationService.sendInquiry(noteInfo);
      response.then((resp) => {
        expect(api.notes.create).toHaveBeenCalledWith({
          feedback_mail: {
            browser: { name: "Safari" },
            email: "jon@example.com",
            engine: { name: "Blink" },
            noteType: "inquiry",
            os: {},
            platform: {},
            question: "what's up?",
          },
        });
        expect(resp).toEqual(successPayload);
      });
    });
  });
});
