import { describe, it } from "@jest/globals";
import { render, screen } from "@testing-library/react";
import expect from "expect";
import React from "react";

import { Mailer } from "./mailer";

describe("Mailer", () => {
  const props = {
    text: "the text",
  };
  beforeEach(() => {
    jest.resetAllMocks();
    render(<Mailer {...props} />);
  });
  it("renders the mailer component", () => {
    expect(screen.getByText(props.text)).toBeInTheDocument();
  });
  it("redirects to the right place on click", () => {
    screen.getByText(props.text).click();
    expect(window.location.assign).toHaveBeenCalledWith(
      "mailto:www@missionartists.org"
    );
  });
});
