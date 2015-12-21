angular.module("mau.models").factory "SearchHit", ngInject (objectRoutingService) ->
  class SearchHit
    constructor: (@hit) ->
      src = @hit._source
      @id = @hit._id
      @type = @hit._type
      @score = @hit._score
      obj = src[@type]
      @image = obj.images?.small
      obj.id = @id
      @osParticipant = obj.os_participant
      switch @type
        when 'artist'
          @name = obj.artist_name
          @icon_class = "fa-user"
          @description = MAU.Utils.ellipsize(obj.bio) if obj.bio?
          @link = objectRoutingService.artistPath(obj)
        when 'studio'
          @name = obj.name
          @icon_class = "fa-building-o"
          @description = obj.address
          @link = objectRoutingService.studioPath(obj)
        when 'art_piece'
          @name = obj.title + " <span class='byline-conjunction'>by</span> <span class='artist-name'>#{obj.artist_name}</span>"
          @icon_class = "fa-picture-o"
          @link = objectRoutingService.artPiecePath(obj)
          @tags = obj.tags
          @tagsForDisplay = ->
          @medium = obj.medium
