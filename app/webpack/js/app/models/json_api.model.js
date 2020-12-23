import { isArray } from "@js/app/helpers";

const matcher = (data, item) => data.id == item.id && data.type === item.type;

export class JsonApiModel {
  constructor(data, included = []) {
    const { id, type, attributes, relationships } = data;
    this.id = id;
    this._type = type;
    for (let attr in attributes) {
      this[attr] = attributes[attr];
    }

    for (let relationship in relationships) {
      const object = relationships[relationship];
      const meta = object.meta;
      if (!meta || (meta && meta.included)) {
        const data = object.data;
        if (!data) {
          continue;
        }
        if (isArray(data)) {
          const items = included.filter((item) =>
            data.find((datum) => matcher(datum, item))
          );
          this[relationship] = items;
        } else {
          this[relationship] = included.find((item) => matcher(data, item));
        }
      }
    }
  }
}
