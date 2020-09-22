import "angular-mocks";
import "./application_events.service";

import angular from "angular";
import expect from "expect";
import { DateTime } from "luxon";

describe("mau.services.applicationEventsService", function () {
  let service, http;

  beforeEach(angular.mock.module("mau.services"));
  beforeEach(
    angular.mock.inject(function ($httpBackend, applicationEventsService) {
      service = applicationEventsService;
      http = $httpBackend;
    })
  );
  afterEach(function () {
    http.verifyNoOutstandingExpectation();
    http.verifyNoOutstandingRequest();
  });
  describe(".list", function () {
    it("calls the apps search endpoint", function () {
      // force PST timezone to avoid weird URI encoding of the + sign in the tz offset
      const since = DateTime.local()
        .minus({ hours: 16 })
        .setZone("America/Los_Angeles")
        .toISO();
      const query = encodeURI(`query[since]=${since}`);
      const mockListOfEvents = [{ id: 1 }, { id: 2 }];
      http.expectGET(`/admin/application_events.json?${query}`).respond({
        application_events: mockListOfEvents,
      });
      const response = service.list({ since });
      http.flush();
      response.$promise.then(function (data) {
        expect(data.map((x) => x.toJSON())).toEqual(mockListOfEvents);
      });
    });
  });
});
