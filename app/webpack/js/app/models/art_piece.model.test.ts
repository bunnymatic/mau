import { ArtPiece } from "./art_piece.model";
import { api } from "@services/api";
import { mocked } from "ts-jest/utils";

jest.mock("@services/api");
const mockApi = mocked(api, true);

describe("ArtPiece", () => {
  it("wraps nested items in models", () => {
    const data = {
      data: {
        id: "36",
        type: "art_piece",
        attributes: {
          artistName: "Rosario AAabraham",
          year: 2001,
          title: "homer",
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
    const model = new ArtPiece(data.data, data.included);
    expect(model).toEqual(
      expect.objectContaining({
        id: "36",
        title: "homer",
        medium: expect.objectContaining({
          id: "3",
          _type: "medium",
          name: "Drawing",
        }),
        tags: expect.arrayContaining([
          expect.objectContaining({
            id: "8",
            _type: "art_piece_tag",
            name: "homer",
          }),
          expect.objectContaining({
            id: "2",
            _type: "art_piece_tag",
            name: "that",
          }),
        ]),
      })
    );
  });


  describe("#image", () => {

    const mockApiImage = api.artPieces.image;

    beforeEach(() => {
      mockApiImage.mockResolvedValue({ url: 'https://theimage.whatever.com/thing.jpg' })
    })
    it("fetches the image via the api", async () => {
      const data = {
        id: "36",
        type: "art_piece",
        attributes: {
          artistName: "Rosario AAabraham",
          year: 2001,
          title: "homer",
        },
      };
      const model = new ArtPiece(data);
      const url = await model.image("original");

      expect(url).toEqual('https://theimage.whatever.com/thing.jpg')
      expect(mockApiImage).toHaveBeenCalledWith(data.id, "original");
    });
  });
});
