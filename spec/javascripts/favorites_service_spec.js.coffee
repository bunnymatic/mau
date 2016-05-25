describe 'mau.services.favoriteService', ->

  beforeEach () ->
    module('mau.services')
    inject ($httpBackend, $q, favoritesService) ->
      @.service = favoritesService
      @.http = $httpBackend
      @.q = $q
    null

  afterEach ->
     @.http.verifyNoOutstandingExpectation()
     @.http.verifyNoOutstandingRequest()

  describe '.add', ->
    it "calls the right endpoint to add this favorite if there is a logged in user", ->
      type = 'Artist'
      id = '12'
      success = { successMessage: true }
      expectedPost = { favorite: { type: type, id: id } }
      @.http.when('GET', '/users/whoami').respond({ "current_user": "the_user" })
      @.http.expect('POST', '/users/the_user/favorites', expectedPost).respond(success)
      response = @.service.add(type, id)
      @.http.flush()
      response.then (data) ->
        expect(data.successMessage).toEqual(true)

    it "returns false and an error message if there is not a logged in user", ->
      @.http.when('GET', '/users/whoami').respond({ "current_user": null })
      response = @.service.add('the_type', 'the_id')
      success = { successMessage: true }
      response.then (data) ->
        expect(data).toEqual('success')
      @.http.flush()
