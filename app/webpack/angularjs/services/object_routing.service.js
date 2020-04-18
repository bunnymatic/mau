import ngInject from "@angularjs/ng-inject";
import angular from "angular";

const objectRoutingService = ngInject(function () {
  return {
    newCmsDocumentPath: function (obj) {
      return (
        "/admin/cms_documents/new?cms_document[page]=" +
        obj.page +
        "&cms_document[section]=" +
        obj.section
      );
    },
    editCmsDocumentPath: function (obj) {
      return "/admin/cms_documents/" + obj.id + "/edit";
    },
    artistPath: function (obj) {
      return this.urlForModel("artist", obj);
    },
    studioPath: function (obj) {
      return this.urlForModel("studio", obj);
    },
    artPiecePath: function (obj) {
      return this.urlForModel("art_piece", obj);
    },
    urlForModel: function (model, obj) {
      const pathPrefix =
        {
          medium: "media",
        }[model] || `${model}s`;
      return ["", pathPrefix, this.toParam(obj)].join("/");
    },
    toParam: function (obj) {
      if (obj != null ? obj.slug : void 0) {
        return obj.slug;
      } else if (obj != null ? obj.id : void 0) {
        return obj.id;
      } else {
        return obj;
      }
    },
  };
});

angular
  .module("mau.services")
  .factory("objectRoutingService", objectRoutingService);
