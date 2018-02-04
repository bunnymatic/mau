// Generated by CoffeeScript 1.12.7
(function() {
  describe('mau.services.currentUserService', function() {
    beforeEach(function() {
      module('mau.services');
      inject(function($httpBackend, $q, currentUserService) {
        this.http = $httpBackend;
        this.q = $q;
        return this.service = currentUserService;
      });
      return null;
    });
    afterEach(function() {
      this.http.verifyNoOutstandingExpectation();
      return this.http.verifyNoOutstandingRequest();
    });
    return describe('.get', function() {
      return it("calls the apps current user endpoint", function() {
        var response, success;
        success = {
          current_user: 'yo'
        };
        this.http.expect('GET', '/users/whoami').respond(success);
        response = this.service.get();
        this.http.flush();
        return response.then(function(data) {
          return expect(data).toEqual('yo');
        });
      });
    });
  });

}).call(this);
