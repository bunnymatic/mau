import esSearchResults from "@fixtures/files/search_results.json";
import { SearchHit } from "@js/app/models/search_hit.model";
import { act, waitFor } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import { SearchResultsPageObject } from "./search_results.po";

describe("SearchResults", () => {
  let po: SearchResultsPageObject;

  beforeEach(() => {
    po = new SearchResultsPageObject();
  });

  describe("when there are no results", () => {
    it("renders an empty element", async () => {
      let container;
      act(() => {
        const result = po.renderComponent();
        container = result.container;
      });

      await waitFor(() => {
        expect(container).toBeEmptyDOMElement();
      });
    });
  });

  describe("when there are results", () => {
    const results = esSearchResults.hits.hits.map((hit) => new SearchHit(hit));
    const [ARTIST_HIT, STUDIO_HIT, ART_PIECE_HIT] = results;

    beforeEach(() => {
      po.setResults(results);
    });

    it("renders all results", async () => {
      act(() => {
        po.renderComponent();
      });

      await waitFor(() => {
        expect(po.findAll("Medium:")).toHaveLength(1);
        expect(po.findAll("Tags:")).toHaveLength(1);
      });
    });

    it("renders the studio properly", async () => {
      act(() => {
        po.renderComponent();
      });

      await waitFor(() => {
        const studioImageLink = po.imageLink(STUDIO_HIT);
        expect(studioImageLink.href).toEqual(
          `http://localhost:3000${STUDIO_HIT.link}`
        );

        const studioMainLink = po.mainLink(STUDIO_HIT);
        expect(studioMainLink.href).toEqual(
          `http://localhost:3000${STUDIO_HIT.link}`
        );

        po.within(studioMainLink, (el) => {
          expect(el.getByText(STUDIO_HIT.object.address)).toBeInTheDocument();
          expect(el.getByText(STUDIO_HIT.name)).toBeInTheDocument();
          const icon = el.getByRole("img");
          expect(icon.classList).toContain("fa-building-o");
        });
      });
    });

    it("renders the art piece properly", async () => {
      act(() => {
        po.renderComponent();
      });

      await waitFor(() => {
        const artPieceImageLink = po.imageLink(ART_PIECE_HIT);
        expect(artPieceImageLink.href).toEqual(
          `http://localhost:3000${ART_PIECE_HIT.link}`
        );

        const artPieceMainLink = po.mainLink(ART_PIECE_HIT);
        expect(artPieceMainLink.href).toEqual(
          `http://localhost:3000${ART_PIECE_HIT.link}`
        );

        po.within(artPieceMainLink, (el) => {
          expect(el.getByText(ART_PIECE_HIT.name)).toBeInTheDocument();
          expect(el.getByText(ART_PIECE_HIT.artistName)).toBeInTheDocument();
          const icon = el.getByRole("img");
          expect(icon.classList).toContain("fa-image");
        });
      });
    });

    it("renders the artist properly", async () => {
      act(() => {
        po.renderComponent();
      });

      await waitFor(() => {
        const artistImageLink = po.imageLink(ARTIST_HIT);
        expect(artistImageLink.href).toEqual(
          `http://localhost:3000${ARTIST_HIT.link}`
        );

        const artistMainLink = po.mainLink(ARTIST_HIT);
        expect(artistMainLink.href).toEqual(
          `http://localhost:3000${ARTIST_HIT.link}`
        );

        po.within(artistMainLink, (el) => {
          expect(el.getByText(ARTIST_HIT.name)).toBeInTheDocument();
          const icon = el.getByRole("img");
          expect(icon.classList).toContain("fa-user");
          const partialDescription = ARTIST_HIT.description
            .substr(0, 40)
            .trim();
          expect(
            el.getByText(partialDescription, { exact: false })
          ).toBeInTheDocument();
        });
      });
    });
  });
});
