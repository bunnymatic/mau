import { api } from "@js/services/api";
import Bowser from "bowser";
import { beforeEach, describe, expect, it, vi } from "vitest";

import * as notificationService from "./notification.service";

vi.mock("bowser");
vi.mock("@services/api");

describe("mau.services.notificationService", function () {
  beforeEach(() => {
    vi.resetAllMocks();

    Bowser.parse = vi.fn().mockReturnValue({
      os: {
        name: "BunnymaticOS",
        version: "12.01",
        versionName: "RockStar",
      },
      platform: {
        type: "Cartoon",
      },
      engine: {
        name: "V8",
        version: "1.2.3",
      },
      browser: {
        name: "Mosaic",
        version: "1100.12",
      },
    });
  });
  const successPayload = { success: true };

  describe(".sendInquiry", function () {
    it("calls the note create endpoint", async function () {
      api.notes.create = vi.fn().mockResolvedValue(successPayload);
      const noteInfo = {
        noteType: "inquiry",
        inquiry: "what's up?",
        email: "jon@example.com",
      };
      const response = await notificationService.sendInquiry(noteInfo);
      expect(api.notes.create).toHaveBeenCalledWith({
        feedback_mail: expect.objectContaining({
          browser: "Mosaic",
          device: "Cartoon V8 v1.2.3",
          email: "jon@example.com",
          noteType: "inquiry",
          os: "BunnymaticOS 12.01 [RockStar]",
          question: "what's up?",
          version: "1100.12",
        }),
      });
      expect(response).toEqual(successPayload);
    });
  });
});
