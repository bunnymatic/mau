import { get as ajaxGet } from "@js/mau_ajax";
import { ArtPiece } from "@models/art_piece.model";
import { Artist } from "@models/artist.model";
import { Studio } from "@models/studio.model";
import { camelizeKeys } from "humps";

const get = (url) => ajaxGet(url).then((data) => camelizeKeys(data));

export const jsonApi = {
  artists: {
    get: (id) => {
      const resp = get(`/api/v2/artists/${id}.json`);
      return resp.then((data) => {
        return new Artist(data.data, data.included);
      });
    },
  },
  artPieces: {
    index: (artistId) => {
      const resp = get(`/api/v2/artists/${artistId}/art_pieces.json`);
      return resp.then((data) => {
        const pieces = data.data;
        const included = data.included;
        return pieces.map((piece) => new ArtPiece(piece, included));
      });
    },
    get: (id) => {
      const resp = get(`/api/v2/art_pieces/${id}.json`);
      return resp.then((data) => {
        return new ArtPiece(data.data, data.included);
      });
    },
  },
  studios: {
    get: (id) => {
      const resp = get(`/api/v2/studios/${id}.json`);
      return resp.then((data) => {
        return new Studio(data.data, data.included);
      });
    },
  },
};
