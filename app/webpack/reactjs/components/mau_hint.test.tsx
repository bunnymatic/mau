import { render } from "@testing-library/react";
import React from "react";
import { describe, expect, it } from "vitest";

import { MauHint } from "./mau_hint";
describe("MauHint", () => {
  it("matches the snapshot", () => {
    const { container } = render(
      <MauHint>
        <span>stuff</span> here
      </MauHint>
    );
    expect(container).toMatchInlineSnapshot(`
      <div>
        <p
          class="inline-hints"
        >
          <span>
            stuff
          </span>
           here
        </p>
      </div>
    `);
  });
  it("when it's empty renders nothing", () => {
    const { container } = render(<MauHint />);
    expect(container).toBeEmptyDOMElement();
  });
});
