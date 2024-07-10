import { isEmpty } from "@js/app/helpers";
import { isObject } from "@js/app/typed_helpers";
import { ellipsizeParagraph } from "@js/app/utils";
import { routing } from "@services/routing.service";

type SourceDetails = Record<
  string,
  Record<string, string> | string | number | boolean | null
>;

type EsSearchSource = Record<string, SourceDetails>;

interface EsSearchResult {
  _type: string | null;
  _score: number;
  _id: string;
  _source: EsSearchSource;
}

export class SearchHit {
  private hit: EsSearchResult;

  constructor(data: EsSearchResult) {
    this.hit = data;
  }

  get src() {
    return this.hit._source;
  }
  get id() {
    return this.hit._id;
  }
  get type() {
    if (this.hit._type === "_doc") {
      return Object.keys(this.src)[0];
    }
    if (this.hit._type) {
      return this.hit._type;
    }
    return Object.keys(this.src)[0];
  }

  get score() {
    return this.hit._score;
  }
  get object() {
    return { id: this.id, ...(this.src[this.type] ?? {}) } as SourceDetails;
  }
  get image() {
    const images = this.object.images;
    if (isEmpty(images)) {
      return null;
    }
    if (!isObject(images)) {
      return null;
    }
    return this.object.images?.small;
  }
  get osParticipant() {
    return this.object.osPartipicant;
  }
  get medium() {
    return this.object.medium;
  }
  get tags() {
    if (!isEmpty(this.object.tags)) {
      return this.object.tags;
    }
    return null;
  }
  get description() {
    if (this.object.bio) {
      return ellipsizeParagraph(this.object.bio);
    }
    if (this.type == "studio") {
      return this.object.address;
    }
    return null;
  }

  get name() {
    switch (this.type) {
      case "studio":
        return this.object.name as string | null;
      case "art_piece":
        return this.object.title as string | null;
      case "artist":
        return this.object.artist_name as string | null;
      default:
        return null;
    }
  }

  get artistName() {
    return this.object.artist_name;
  }

  get iconClass() {
    return {
      studio: "fa fa-building-o",
      art_piece: "fa fa-image",
      artist: "fa fa-user",
    }[this.type];
  }
  get link() {
    switch (this.type) {
      case "studio":
        return routing.studioPath(this.object);
      case "art_piece":
        return routing.artPiecePath(this.object);
      case "artist":
        return routing.artistPath(this.object);
      default:
        return "#";
    }
  }
}
