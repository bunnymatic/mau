import { describe, expect, it } from "@jest/globals";
import { render } from "@testing-library/react";
import React from "react";

import { LinkIf } from "./link_if";

describe("LinkIf", () => {
  it("renders a link if href is present", () => {
    const { container } = render(<LinkIf href="/this" label="whatever" />);
    expect(container).toMatchInlineSnapshot(`
      <div>
        <a
          class="link-if"
          href="/this"
          title="whatever"
        >
          whatever
        </a>
      </div>
    `);
  });
  it("renders a span if href is not present", () => {
    const { container } = render(<LinkIf label="whatever" />);
    expect(container).toMatchInlineSnapshot(`
    <div>
      <span
        class="link-if"
      >
        whatever
      </span>
    </div>
    `);
  });
});
