describe 'mau.directives.favoriteThis', ->

  artistTemplate = "<favorite-this ng-type='Artist', ng-id='3'></favorite-this>";
  artPieceTemplate = "<favorite-this ng-type='ArtPiece' ng-id='2'></favorite-this>";

  beforeEach module('mau.directives')
  beforeEach module('templates')

  describe 'with an art piece', ->
    scope = {}

    it 'sets up the directive with the art piece attributes', ->
      e = compileTemplate(artistTemplate, scope)
      $(e).find('a').click()


    it 'submits a request to favorite that art piece when clicked on', ->
      e = compileTemplate(artPieceTemplate, scope)
      $(e).find('a').click();
