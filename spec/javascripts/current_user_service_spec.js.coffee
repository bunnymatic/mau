describe 'mau.services.currentUserService', ->

  beforeEach () ->
    module('mau.services')
    inject ($httpBackend, $q, currentUserService) ->
      @.http = $httpBackend
      @.q = $q
      @.service = currentUserService
    null

  afterEach ->
     @.http.verifyNoOutstandingExpectation()
     @.http.verifyNoOutstandingRequest()

  describe '.get', ->
    it "calls the apps current user endpoint", ->
      success = { current_user: 'yo' }
      @.http.expect('GET', '/users/whoami').respond(success)
      response = @.service.get()
      @.http.flush()
      response.then (data) ->
        expect(data).toEqual( 'yo' )
