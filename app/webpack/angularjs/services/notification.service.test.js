import "angular-mocks";
import "./notification.service";

import { api } from "@services/api";
import angular from "angular";
import expect from "expect";

jest.mock("@services/api");

describe("mau.services.notificationService", function () {
  let svc;

  const data = { whatever: "man", inquiry: "The question" };

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.module(function ($provide) {
      $provide.value("$window", {
        navigator: {
          userAgent:
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Safari/605.1.15",
        },
      });
    })
  );

  beforeEach(
    angular.mock.inject(function (notificationService) {
      svc = notificationService;
    })
  );
  beforeEach(() => {
    jest.resetAllMocks();
  });

  describe("sendInquiry", function () {
    describe("when /api/notes works", () => {
      beforeEach(() => {
        api.notes.create = jest.fn().mockResolvedValue({});
      });

      it("posts to /api/notes", async () => {
        await svc.sendInquiry(data);
        expect(api.notes.create).toHaveBeenCalledWith({
          feedback_mail: {
            browser: { name: "Safari", version: "14.0.2" },
            engine: { name: "WebKit", version: "605.1.15" },
            os: { name: "macOS", version: "10.14.6", versionName: "Mojave" },
            platform: { type: "desktop", vendor: "Apple" },
            question: "The question",
            whatever: "man",
          },
        });
      });
    });
    describe("when the notes api fails", () => {
      beforeEach(() => {
        api.notes.create = jest.fn().mockRejectedValue(new Error("crap"));
      });
      it("raises error callback", async () => {
        try {
          await svc.sendInquiry(data);
          // never hits here
          expect(true).toEqual(false);
        } catch (e) {
          expect(e).toEqual(new Error("crap"));
        }
      });
    });
  });
});
