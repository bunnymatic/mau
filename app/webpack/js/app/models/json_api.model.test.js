import { describe, expect, it } from "vitest";

import { JsonApiModel } from "./json_api.model";

describe("JsonApiModel", () => {
  it("handles a simple json api data structure", () => {
    const data = {
      data: {
        id: 5,
        type: "whatever",
        attributes: {
          name: "a thing",
        },
      },
    };
    const model = new JsonApiModel(data.data, data.included);
    expect(model).toEqual(
      expect.objectContaining({
        id: 5,
        _type: "whatever",
        name: "a thing",
      })
    );
  });

  it("handles a complicated json api data structure with relationships", () => {
    const data = {
      data: {
        id: "36",
        type: "art_piece",
        attributes: {
          artistName: "Rosario AAabraham",
          year: 2001,
          title: "homer",
          imageUrls: {
            thumb: "thumb 1",
            small: "thumb 2",
          },
        },
        relationships: {
          artist: { meta: { included: false } },
          tags: {
            data: [
              { type: "art_piece_tag", id: "8" },
              { type: "art_piece_tag", id: "2" },
            ],
          },
          medium: { data: { type: "medium", id: "3" } },
        },
      },
      included: [
        { id: "8", type: "art_piece_tag", attributes: { name: "homer" } },
        { id: "2", type: "art_piece_tag", attributes: { name: "that" } },
        { id: "4", type: "art_piece_tag", attributes: { name: "this" } },
        { id: "14", type: "medium", attributes: { name: "Painting - Oil" } },
        { id: "3", type: "medium", attributes: { name: "Drawing" } },
      ],
    };
    const model = new JsonApiModel(data.data, data.included);
    expect(model).toEqual(
      expect.objectContaining({
        id: "36",
        title: "homer",
        medium: expect.objectContaining({
          id: "3",
          type: "medium",
          attributes: { name: "Drawing" },
        }),
        tags: expect.arrayContaining([
          { id: "8", type: "art_piece_tag", attributes: { name: "homer" } },
          { id: "2", type: "art_piece_tag", attributes: { name: "that" } },
        ]),
      })
    );
  });
});
