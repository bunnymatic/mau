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

    it "returns a message if there is not a logged in user", ->
      @.http.when('GET', '/users/whoami').respond({ "current_user": null })
      response = @.service.add('the_type', 'the_id')
      @.http.flush()
      response.then (data) ->
        expect(data).toEqual { message: "You need to login before you can favorite things" }

    it "returns a message if there is favoriting fails", ->
      expectedPost = { favorite: { type: null, id: null } }
      @.http.when('GET', '/users/whoami').respond({ "current_user": 'somebody' })
      @.http.expect('POST', '/users/somebody/favorites',expectedPost).respond(500, {})
      response = @.service.add(null, null)
      @.http.flush()
      response.then (data) ->
        expect(data).toEqual { message: "That item doesn't seem to be available to favorite.  If you think it should be, please drop us a note and we'll look into it." }
