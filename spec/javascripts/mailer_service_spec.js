describe("mau.services.mailerService", function () {
  var svc;
  svc = null;
  beforeEach(module("mau.services"));
  beforeEach(inject(function (mailerService) {
    return (svc = mailerService);
  }));
  describe("#mailToLink", function () {
    it("returns the right email link with all things specified", function () {
      return expect(
        svc.mailToLink("the subject", "email_user", "email_domain")
      ).toEqual("mailto:www@email_domain?subject=the%20subject");
    });
    it("falls back to missionartists.org if no domain is specified", function () {
      return expect(svc.mailToLink("the subject", "email_user")).toEqual(
        "mailto:www@missionartists.org?subject=the%20subject"
      );
    });
    it("falls back to www if the user is not info, www, feedback, or mau", function () {
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
