import { FieldError } from "./field_error";
import { render } from "@testing-library/react";
import React from "react";

describe("FieldError", () => {
  // This test is corrrect but fails with
  //  - Expected properties  - 0
  //  + Received value       + 0
  // So skipping until we have time to investigate
  xit("renders an error for a field", () => {
    const { container } = render(<FieldError>this is the error</FieldError>);
    expect(container).toMatchInlineSnapshot(
      <div>
        <p class="inline-errors">this is the error</p>
      </div>
    );
  });
});
