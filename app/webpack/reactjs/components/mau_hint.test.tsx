import { MauHint } from "./mau_hint";
import { render } from "@testing-library/react";
import React from "react";

describe("MauHint", () => {
  it("matches the snapshot", () => {
    const { container } = render(
      <MauHint>
        <span>stuff</span> here
      </MauHint>
    );
    expect(container).toMatchInlineSnapshot(`
      <div>
        <div
          class="inline-hints"
        >
          <span>
            stuff
          </span>
           here
        </div>
      </div>
    `);
  });
  it("when it's empty renders nothing", () => {
    const { container } = render(<MauHint />);
    expect(container).toBeEmptyDOMElement();
  });
});
