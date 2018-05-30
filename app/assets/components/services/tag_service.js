// Generated by CoffeeScript 1.12.7
(function() {
  var tagService;

  tagService = ngInject(function($resource) {
    var tags;
    tags = $resource(
      "/art_piece_tags/:id",
      {},
      {
        get: {
          method: "GET",
          cache: true
        }
      }
    );
    return {
      get: function(id) {
        return tags.get({
          id: id
        });
      }
    };
  });

  angular.module("mau.services").factory("tagService", tagService);
}.call(this));
