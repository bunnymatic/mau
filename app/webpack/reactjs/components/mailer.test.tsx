import { render, screen } from "@testing-library/react";
import React from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { Mailer } from "./mailer";

describe("Mailer", () => {
  const props = {
    text: "the text",
  };
  beforeEach(() => {
    vi.resetAllMocks();
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
