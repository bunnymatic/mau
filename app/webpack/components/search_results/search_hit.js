import { ellipsize } from "@js/mau/utils";
import angular from "angular";
import ngInject from "@js/ng-inject";

const SearchHit = ngInject(function (objectRoutingService) {
  return function (hit) {
    var ref;
    this.hit = hit;
    const src = this.hit._source;
    this.id = this.hit._id;
    this.type = this.hit._type;
    // the `type` field was mapped to the ruby model in the past
    // but recently has been replaced with `_doc` (ES 6.x something) so...
    if (this.type === "_doc") {
      this.type = Object.keys(src)[0];
    }
    this.score = this.hit._score;
    const obj = src[this.type];
    this.image = (ref = obj.images) != null ? ref.small : void 0;
    obj.id = this.id;
    this.osParticipant = obj.os_participant;
    switch (this.type) {
      case "artist":
        this.name = obj.artist_name;
        this.icon_class = "fa fa-user";
        if (obj.bio != null) {
          this.description = ellipsize(obj.bio);
        }
        this.link = objectRoutingService.artistPath(obj);
        break;
      case "studio":
        this.name = obj.name;
        this.icon_class = "far fa-building";
        this.description = obj.address;
        this.link = objectRoutingService.studioPath(obj);
        break;
      case "art_piece":
        this.name =
          obj.title +
          (" <span class='byline-conjunction'>by</span> <span class='artist-name'>" +
            obj.artist_name +
            "</span>");
        this.icon_class = "far fa-image";
        this.link = objectRoutingService.artPiecePath(obj);
        this.tags = obj.tags;
        this.tagsForDisplay = function () {};
        this.medium = obj.medium;
    }
  };
});

angular.module("mau.models").factory("SearchHit", SearchHit);
