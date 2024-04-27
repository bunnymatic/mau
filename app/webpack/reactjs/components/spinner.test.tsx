import { render } from "@testing-library/react";
import React from "react";
import { describe, expect, it } from "vitest";

import { Spinner } from "./spinner";

describe("Spinner", () => {
  it("looks right (snapshot)", () => {
    const { container } = render(<Spinner />);
    expect(container).toMatchSnapshot();
  });
});
