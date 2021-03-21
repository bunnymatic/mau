import { some } from "@js/app/helpers";
import { ArtPieceTag } from "@models/art_piece_tag.model";
import { JsonApiModel } from "@models/json_api.model";
import { Medium } from "@models/medium.model";

export class ArtPiece extends JsonApiModel {
  constructor(data, included) {
    super(data, included);

    if (this.medium) {
      this.medium = new Medium(this.medium);
    }

    if (some(this.tags)) {
      this.tags = this.tags.map((tag) => new ArtPieceTag(tag));
    }
  }

  hasSold() {
    return !!this.soldAt;
  }
}
