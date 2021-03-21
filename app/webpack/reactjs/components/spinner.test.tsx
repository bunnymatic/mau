import { describe, expect, it } from "@jest/globals";
import { render } from "@testing-library/react";
import React from "react";

import { Spinner } from "./spinner";

describe("Spinner", () => {
  it("looks right (snapshot)", () => {
    const { container } = render(<Spinner />);
    expect(container).toMatchSnapshot();
  });
});
