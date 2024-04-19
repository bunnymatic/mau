import { render } from "@testing-library/react";
import React from "react";
import { describe, expect, it } from "vitest";

import { ArtPieceTagLink } from "./art_piece_tag_link";

describe("ArtPieceLink", () => {
  let tag = { name: "my tag", id: 12, slug: "my-tag" };
  let container;

  beforeEach(function () {
    const result = render(<ArtPieceTagLink tag={tag} />);
    container = result.container;
  });

  it("uses id for the tag path", function () {
    expect(container).toMatchInlineSnapshot(`
      <div>
        <a
          class="art-piece-tag-link"
          href="/art_piece_tags/my-tag"
        >
          my tag
        </a>
      </div>
    `);
  });
});
