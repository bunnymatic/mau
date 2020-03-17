describe("mau.services.envService", function() {
  var svc;
  svc = null;
  beforeEach(module("mau.services"));

  describe("when window.__env is test", function() {
    beforeEach(
      module(function($provide) {
        $provide.value("$window", { __env: "test" });
      })
    );
    beforeEach(inject(function(envService) {
      svc = envService;
    }));
    it("isTest returns true", function() {
      expect(svc.isTest()).toBeTruthy();
    });
    it("isDevelopment returns false", function() {
      expect(svc.isDevelopment()).toBeFalsy();
    });
    it("isProduction returns false", function() {
      expect(svc.isProduction()).toBeFalsy();
    });
  });

  describe("when window.__env is development", function() {
    beforeEach(
      module(function($provide) {
        $provide.value("$window", { __env: "development" });
      })
    );
    beforeEach(inject(function(envService) {
      svc = envService;
    }));
    it("isTest returns false", function() {
      expect(svc.isTest()).toBeFalsy();
    });
    it("isDevelopment returns true", function() {
      expect(svc.isDevelopment()).toBeTruthy();
    });
    it("isProduction returns false", function() {
      expect(svc.isProduction()).toBeFalsy();
    });
  });

  describe("when window.__env is acceptance", function() {
    beforeEach(
      module(function($provide) {
        $provide.value("$window", { __env: "acceptance" });
      })
    );
    beforeEach(inject(function(envService) {
      svc = envService;
    }));
    it("isTest returns false", function() {
      expect(svc.isTest()).toBeFalsy();
    });
    it("isDevelopment returns false", function() {
      expect(svc.isDevelopment()).toBeFalsy();
    });
    it("isProduction returns true", function() {
      expect(svc.isProduction()).toBeTruthy();
    });
  });

  describe("when window.__env is production", function() {
    beforeEach(
      module(function($provide) {
        $provide.value("$window", { __env: "production" });
      })
    );
    beforeEach(inject(function(envService) {
      svc = envService;
    }));
    it("isTest returns false", function() {
      expect(svc.isTest()).toBeFalsy();
    });
    it("isDevelopment returns false", function() {
      expect(svc.isDevelopment()).toBeFalsy();
    });
    it("isProduction returns true", function() {
      expect(svc.isProduction()).toBeTruthy();
    });
  });
});
