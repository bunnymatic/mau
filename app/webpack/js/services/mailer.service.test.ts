import { mailToLink } from "./mailer.service";

import { describe, it } from '@jest/globals'
import expect from "expect";

describe("mau.services.mailerService", () => {

  describe("#mailToLink", () => {
    it("returns the right email link with all things specified", () => {
      expect(
        mailToLink("the subject", "email_user", "email_domain")
      ).toEqual("mailto:www@email_domain?subject=the%20subject");
    });
    it("falls back to missionartists.org if no domain is specified", () => {
      expect(mailToLink("the subject", "email_user")).toEqual(
        "mailto:www@missionartists.org?subject=the%20subject"
      );
    });
    it("falls back to www if the user is not info, www, feedback, or mau", () => {
      expect(mailToLink("the subject", "email_user")).toEqual(
        "mailto:www@missionartists.org?subject=the%20subject"
      );
      expect(mailToLink("the subject", "info")).toEqual(
        "mailto:info@missionartists.org?subject=the%20subject"
      );
      expect(mailToLink("the subject", "feedback")).toEqual(
        "mailto:feedback@missionartists.org?subject=the%20subject"
      );
      expect(mailToLink("the subject", "mau")).toEqual(
        "mailto:mau@missionartists.org?subject=the%20subject"
      );
      expect(mailToLink("the subject", "www")).toEqual(
        "mailto:www@missionartists.org?subject=the%20subject"
      );
    });
  });
});
