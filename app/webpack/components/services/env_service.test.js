import expect from "expect";
import angular from "angular";
import "angular-mocks";
import "./env_service";

describe("mau.services.envService", function () {
  let svc;

  beforeEach(angular.mock.module("mau.services"));

  describe("when window.__env is test", function () {
    beforeEach(
      angular.mock.module(function ($provide) {
        $provide.value("$window", { __env: "test" });
      })
    );
    beforeEach(
      angular.mock.inject(function (envService) {
        svc = envService;
      })
    );

    it("isTest returns true", function () {
      expect(svc.isTest()).toBeTruthy();
    });
    it("isDevelopment returns false", function () {
      expect(svc.isDevelopment()).toBeFalsy();
    });
    it("isProduction returns false", function () {
      expect(svc.isProduction()).toBeFalsy();
    });
  });

  describe("when window.__env is development", function () {
    beforeEach(
      angular.mock.module(function ($provide) {
        $provide.value("$window", { __env: "development" });
      })
    );
    beforeEach(
      angular.mock.inject(function (envService) {
        svc = envService;
      })
    );
    it("isTest returns false", function () {
      expect(svc.isTest()).toBeFalsy();
    });
    it("isDevelopment returns true", function () {
      expect(svc.isDevelopment()).toBeTruthy();
    });
    it("isProduction returns false", function () {
      expect(svc.isProduction()).toBeFalsy();
    });
  });

  describe("when window.__env is acceptance", function () {
    beforeEach(
      angular.mock.module(function ($provide) {
        $provide.value("$window", { __env: "acceptance" });
      })
    );
    beforeEach(
      angular.mock.inject(function (envService) {
        svc = envService;
      })
    );
    it("isTest returns false", function () {
      expect(svc.isTest()).toBeFalsy();
    });
    it("isDevelopment returns false", function () {
      expect(svc.isDevelopment()).toBeFalsy();
    });
    it("isProduction returns true", function () {
      expect(svc.isProduction()).toBeTruthy();
    });
  });

  describe("when window.__env is production", function () {
    beforeEach(
      angular.mock.module(function ($provide) {
        $provide.value("$window", { __env: "production" });
      })
    );
    beforeEach(
      angular.mock.inject(function (envService) {
        svc = envService;
      })
    );
    it("isTest returns false", function () {
      expect(svc.isTest()).toBeFalsy();
    });
    it("isDevelopment returns false", function () {
      expect(svc.isDevelopment()).toBeFalsy();
    });
    it("isProduction returns true", function () {
      expect(svc.isProduction()).toBeTruthy();
    });
  });
});
