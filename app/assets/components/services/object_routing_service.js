// Generated by CoffeeScript 1.12.7
(function() {
  var objectRoutingService;

  objectRoutingService = ngInject(function() {
    return {
      artistPath: function(obj) {
        return this.urlForModel("artist", obj);
      },
      studioPath: function(obj) {
        return this.urlForModel("studio", obj);
      },
      artPiecePath: function(obj) {
        return this.urlForModel("art_piece", obj);
      },
      urlForModel: function(model, obj) {
        return "/" + model + "s/" + (this.toParam(obj));
      },
      toParam: function(obj) {
        if (obj != null ? obj.slug : void 0) {
          return obj.slug;
        } else if (obj != null ? obj.id : void 0) {
          return obj.id;
        } else {
          return obj;
        }
      }
    };
  });

  angular.module("mau.services").factory("objectRoutingService", objectRoutingService);

}).call(this);
