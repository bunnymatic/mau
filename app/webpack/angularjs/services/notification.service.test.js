import "angular-mocks";
import "ua-device-detector";
import "ng-device-detector";
import "./notification.service";

import angular from "angular";
import expect from "expect";

describe("mau.services.notificationService", function () {
  let svc, http;

  const browserData = {
    browser: "Lynx",
    device: "TRS-80",
    os: "ms-dos",
  };

  const data = { whatever: "man" };
  const successCb = jest.fn();
  const errorCb = jest.fn();

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function (
      $httpBackend,
      deviceDetector,
      notificationService
    ) {
      http = $httpBackend;
      svc = notificationService;
      deviceDetector.browser = browserData.browser;
      deviceDetector.device = browserData.device;
      deviceDetector.os = browserData.os;
    })
  );
  beforeEach(() => {
    jest.resetAllMocks();
  });
  afterEach(function () {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });

  describe("sendInquiry", function () {
    describe("when /api/notes works", () => {
      beforeEach(() => {
        http
          .expect("POST", "/api/notes", {
            feedback_mail: { ...data, ...browserData },
          })
          .respond({ success: true });
      });

      it("posts to /api/notes", () => {
        svc.sendInquiry(data, successCb, errorCb);
        http.flush();
      });
      it("calls the success callback", () => {
        svc.sendInquiry(data, successCb, errorCb);
        http.flush();
        expect(successCb).toHaveBeenCalled();
      });
    });
    describe("when the notes api fails", () => {
      beforeEach(() => {
        http
          .expect("POST", "/api/notes", {
            feedback_mail: { ...data, ...browserData },
          })
          .respond(400, {
            success: false,
            error_messages: ["whatever failed"],
          });
      });
      it("calls the error callback", () => {
        svc.sendInquiry(data, successCb, errorCb);
        http.flush();
        expect(errorCb).toHaveBeenCalled();
      });
    });
  });
});
