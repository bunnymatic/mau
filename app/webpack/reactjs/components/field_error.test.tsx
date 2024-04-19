import { render } from "@testing-library/react";
import React from "react";
import { describe, expect, it } from "vitest";

import { FieldError } from "./field_error";

describe("FieldError", () => {
  it("renders an error for a field", () => {
    const { container } = render(<FieldError>this is the error</FieldError>);
    // this indentation is crap and this is why snapshot testing is fragile and stupid
    expect(container).toMatchInlineSnapshot(
      `<div>
  <p
    class="inline-errors"
  >
    this is the error
  </p>
</div>`
    );
  });
});
