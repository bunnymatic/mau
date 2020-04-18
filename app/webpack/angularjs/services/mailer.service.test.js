import "angular-mocks";
import "./mailer.service";

import angular from "angular";
import expect from "expect";

describe("mau.services.mailerService", () => {
  let svc;

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function (mailerService) {
      svc = mailerService;
    })
  );

  describe("#mailToLink", () => {
    it("returns the right email link with all things specified", () => {
      expect(
        svc.mailToLink("the subject", "email_user", "email_domain")
      ).toEqual("mailto:www@email_domain?subject=the%20subject");
    });
    it("falls back to missionartists.org if no domain is specified", () => {
      expect(svc.mailToLink("the subject", "email_user")).toEqual(
        "mailto:www@missionartists.org?subject=the%20subject"
      );
    });
    it("falls back to www if the user is not info, www, feedback, or mau", () => {
      expect(svc.mailToLink("the subject", "email_user")).toEqual(
        "mailto:www@missionartists.org?subject=the%20subject"
      );
      expect(svc.mailToLink("the subject", "info")).toEqual(
        "mailto:info@missionartists.org?subject=the%20subject"
      );
      expect(svc.mailToLink("the subject", "feedback")).toEqual(
        "mailto:feedback@missionartists.org?subject=the%20subject"
      );
      expect(svc.mailToLink("the subject", "mau")).toEqual(
        "mailto:mau@missionartists.org?subject=the%20subject"
      );
      expect(svc.mailToLink("the subject", "www")).toEqual(
        "mailto:www@missionartists.org?subject=the%20subject"
      );
    });
  });
});
