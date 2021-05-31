import { isEmpty } from "@js/app/helpers";
import { ellipsizeParagraph } from "@js/app/utils";
import { routing } from "@services/routing.service";

type SourceDetails = Record<
  string,
  Record<string, string> | string | number | boolean | null
>;

type EsSearchSource = Record<string, SourceDetails>;

interface EsSearchResult {
  _type: string;
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
    return this.hit._type;
  }
  get score() {
    return this.hit._score;
  }
  get object() {
    return { id: this.id, ...(this.src[this.type] ?? {}) } as SourceDetails;
  }
  get image() {
    if (isEmpty(this.object.images)) {
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
        return this.object.name;
      case "art_piece":
        return this.object.title;
      case "artist":
        return this.object.artist_name;
      default:
        return null;
    }
  }

  get artistName() {
    return this.object.artist_name;
  }

  get iconClass() {
    return {
      studio: "far fa-building",
      art_piece: "far fa-image",
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
