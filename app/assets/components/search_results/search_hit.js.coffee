class SearchHit
  constructor: (@hit) ->
    src = @hit._source
    @id = @hit._id
    @type = @hit._type
    @score = @hit._score
    obj = src[@type]
    console.log obj
    @image = obj.images?.small
    switch @type
      when 'artist'
        @name = obj.artist_name
        @icon_class = "fa-user"
        @description = MAU.Utils.ellipsize(obj.bio) if obj.bio?
      when 'studio'
        @name = obj.name
        @icon_class = "fa-building-o"
        @description = obj.address
      when 'art_piece'
        @name = obj.title
        @icon_class = "fa-picture-o"
        @description = obj.medium?.name
    
angular.module("mau.models").factory "SearchHit", -> SearchHit
