import { JsonApiModel } from "@models/json_api.model";

export class Artist extends JsonApiModel {
  get hasAddress() {
    return Boolean(this.streetAddress);
  }
}
