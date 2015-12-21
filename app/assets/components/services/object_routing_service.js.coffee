objectRoutingService = ngInject () ->
  artistPath: (obj) ->
    @urlForModel("artist", obj);
  studioPath: (obj) ->
    @urlForModel("studio", obj);
  artPiecePath: (obj) ->
    @urlForModel("art_piece", obj)
  urlForModel: (model, obj) ->
    "/#{model}s/#{@toParam(obj)}"
  toParam: (obj) ->
    if obj?.slug
      obj.slug
    else if obj?.id
      obj.id
    else
      obj

angular.module("mau.services").factory("objectRoutingService", objectRoutingService)
