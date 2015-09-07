describe 'mau.services.objectRoutingService', ->

  svc = null

  beforeEach module('mau.services')

  beforeEach inject( (objectRoutingService)->
    svc = objectRoutingService
  )

  describe '#artistPath', ->
    it 'returns the right path for an artist with an id', ->
      expect(svc.artistPath({id: 'whatever'})).toEqual('/artists/whatever')
    it 'returns the right path for an artist with an slug', ->
      expect(svc.artistPath({slug: 'whatever'})).toEqual('/artists/whatever')
    it 'returns the right path for an id', ->
      expect(svc.artistPath('whatever')).toEqual('/artists/whatever')

  describe '#studioPath', ->
    it 'returns the right path for an artist with an id', ->
      expect(svc.studioPath({id: 'whatever'})).toEqual('/studios/whatever')
    it 'returns the right path for an artist with an slug', ->
      expect(svc.studioPath({slug: 'whatever'})).toEqual('/studios/whatever')
    it 'returns the right path for an id', ->
      expect(svc.studioPath('whatever')).toEqual('/studios/whatever')

  describe '#artPiecePath', ->
    it 'returns the right path for an artist with an id', ->
      expect(svc.artPiecePath({id: 'whatever'})).toEqual('/art_pieces/whatever')
    it 'returns the right path for an artist with an slug', ->
      expect(svc.artPiecePath({slug: 'whatever'})).toEqual('/art_pieces/whatever')
    it 'returns the right path for an id', ->
      expect(svc.artPiecePath('whatever')).toEqual('/art_pieces/whatever')
