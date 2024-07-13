import { render } from "@testing-library/react";
import React from "react";
import { beforeEach, describe, expect, it } from "vitest";

import { MediumLink } from "./medium_link";

describe("MediumLink", () => {
  let medium = { name: "my medium", id: 12, slug: "my-tag" };
  let container;

  beforeEach(function () {
    const result = render(<MediumLink medium={medium} />);
    container = result.container;
  });

  it("uses id for the medium path", function () {
    expect(container).toMatchInlineSnapshot(`
      <div>
        <a
          class="medium-link"
          href="/media/my-tag"
        >
          my medium
        </a>
      </div>
    `);
  });
});
