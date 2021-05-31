import * as types from "@reactjs/types";

export const routing = {
  newCmsDocumentPath: function (obj: Partial<types.CmsDocument>): string {
    return (
      "/admin/cms_documents/new?cms_document[page]=" +
      obj.page +
      "&cms_document[section]=" +
      obj.section
    );
  },
  editCmsDocumentPath: function (obj: Partial<types.CmsDocument>): string {
    return "/admin/cms_documents/" + obj.id + "/edit";
  },
  artistPath: function (
    obj: Partial<types.Artist> | Record<string, string>
  ): string {
    return this.urlForModel("artist", obj);
  },
  studioPath: function (
    obj: Partial<types.Studio> | Record<string, string>
  ): string {
    return this.urlForModel("studio", obj);
  },
  artPiecePath: function (
    obj: Partial<types.ArtPiece> | Record<string, string>
  ): string {
    return this.urlForModel("art_piece", obj);
  },
  urlForModel: function (model: string, obj: any): string {
    const pathPrefix =
      {
        medium: "media",
      }[model] || `${model}s`;
    return ["", pathPrefix, this.toParam(obj)].join("/");
  },
  toParam: function (obj: any): any {
    if (obj != null ? obj.slug : void 0) {
      return obj.slug;
    } else if (obj != null ? obj.id : void 0) {
      return obj.id;
    } else {
      return obj;
    }
  },
};
