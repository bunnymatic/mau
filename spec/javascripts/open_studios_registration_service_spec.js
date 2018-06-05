(function() {
  describe("mau.services.openStudiosRegistrationService", function() {
    beforeEach(function() {
      module("mau.services");
      inject(function($httpBackend, $q, openStudiosRegistrationService) {
        this.service = openStudiosRegistrationService;
        this.http = $httpBackend;
        this.q = $q;
      });
      return null;
    });
    afterEach(function() {
      this.http.verifyNoOutstandingExpectation();
      this.http.verifyNoOutstandingRequest();
    });
    describe(".register", function() {
      it("calls the right endpoint to register this artist for open studios", function() {
        var success = jasmine.createSpy("success");
        var failure = jasmine.createSpy("failure");
        var inputData = {
          participation: false
        };
        var successResponse = {
          success: true,
          participating: false
        };
        this.http.when("GET", "/users/whoami").respond({
          current_user: {
            id: 1,
            login: "the_user",
            slug: "the_user_slug"
          }
        });
        this.http
          .expect(
            "POST",
            "/api/artists/the_user_slug/register_for_open_studios"
          )
          .respond(successResponse);

        var response = this.service.register(inputData, success, failure);
        this.http.flush();
        response.then(function(_data) {
          expect(success).toHaveBeenCalled();
        });
      });

      it("calls the failure callback if sommething goes wrong", function() {
        var success = jasmine.createSpy("success");
        var failure = jasmine.createSpy("failure");
        var inputData = {
          participation: false
        };
        this.http.when("GET", "/users/whoami").respond({
          current_user: {
            id: 1,
            login: "the_user",
            slug: "the_user_slug"
          }
        });
        this.http
          .expect(
            "POST",
            "/api/artists/the_user_slug/register_for_open_studios"
          )
          .respond(400, {});

        var response = this.service.register(inputData, success, failure);
        this.http.flush();
        response.then(function(_data) {
          expect(failure).toHaveBeenCalled();
        });
      });
    });
  });
}.call(this));
