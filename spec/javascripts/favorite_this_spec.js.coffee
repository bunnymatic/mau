describe 'mau.directives.favoriteThis', ($q) ->

  artistTemplate = "<favorite-this object-type='Artist', object-id='3'></favorite-this>"
  artPieceTemplate = "<favorite-this object-type='ArtPiece' object-id='2'></favorite-this>"
  blankTemplate = "<favorite-this></favorite-this>"


  beforeEach module('mau.directives')
  beforeEach module('templates')
  beforeEach module('mau.services')
  beforeEach ->
    inject ($q, currentUserService, favoritesService) ->
      @.favoritesService = favoritesService
      spyOn(currentUserService, 'get').and.callFake () ->
        $q.when({current_user: 'bmatic'}, {current_user: null})
      spyOn(@.favoritesService, 'add').and.callFake () ->
        success =
          artist:
            id: 'artistid'
        error = {}
        $q.when( success , error )

  describe 'with an art piece', ->
    scope = {}

    it 'sets up the directive with the art piece attributes', ->
      e = compileTemplate(artistTemplate, scope)
      $(e).find('a').click()
      expect(@.favoritesService.add).toHaveBeenCalled()
      args = @.favoritesService.add.calls.mostRecent().args
      expect(args).toEqual ['Artist', '3']


    it 'submits a request to favorite that art piece when clicked on', ->
      e = compileTemplate(artPieceTemplate, scope)
      $(e).find('a').click();
      expect(@.favoritesService.add).toHaveBeenCalled()
      args = @.favoritesService.add.calls.mostRecent().args
      expect(args).toEqual ['ArtPiece', '2']

    it 'calls the service with empties if there is no object or id', ->
      e = compileTemplate(blankTemplate, scope)
      $(e).find('a').click();
      expect(@.favoritesService.add).toHaveBeenCalled()
      args = @.favoritesService.add.calls.mostRecent().args
      expect(args).toEqual [ undefined, undefined ]
