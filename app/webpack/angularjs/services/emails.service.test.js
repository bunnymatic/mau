import "angular-mocks";
import "./emails.service";

import angular from "angular";
import expect from "expect";

describe("mau.services.emailsService", function () {
  let service, http;

  const emailList = { id: 10, type: "Watchers" };
  const email = { id: 4, name: "Eyeball", email: "eyeball@example.com" };

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function ($httpBackend, emailsService) {
      service = emailsService;
      http = $httpBackend;
    })
  );
  afterEach(function () {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });
  describe(".query", function () {
    it("calls the admin email query api endpoint", function () {
      http.expectGET(`/admin/email_lists/${emailList.id}/emails`).respond({
        emails: [email],
      });
      const response = service.query({ email_list_id: emailList.id });
      http.flush();
      response.$promise.then(function (data) {
        expect(data.map((d) => d.toJSON())).toEqual([email]);
      });
    });
  });

  describe(".get", function () {
    it("calls the admin email get api endpoint", function () {
      const email = { id: 10, title: "Artperson" };
      http
        .expectGET(`/admin/email_lists/${emailList.id}/emails/${email.id}`)
        .respond({
          email,
        });
      const response = service.get({
        email_list_id: emailList.id,
        id: email.id,
      });
      http.flush();
      response.$promise.then(function (data) {
        expect(data.toJSON()).toEqual(email);
      });
    });
  });

  describe(".save", function () {
    it("calls the admin email list save api endpoint", function () {
      const params = {
        email_list_id: emailList.id,
        id: email.id,
        name: "new name",
      };
      http
        .expectPOST(
          `/admin/email_lists/${emailList.id}/emails/${email.id}`,
          params
        )
        .respond({
          email,
        });
      const response = service.save(params);
      http.flush();
      response.$promise.then(function (data) {
        expect(data.toJSON()).toEqual({ email });
      });
    });
  });
});
