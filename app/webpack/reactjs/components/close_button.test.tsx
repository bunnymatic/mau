import { fireEvent, render, screen } from "@testing-library/react";
import React from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { CloseButton } from "./close_button";

describe("CloseButton", () => {
  let mockHandleClose = vi.fn();
  let container;

  beforeEach(() => {
    vi.resetAllMocks();
    const rendered = render(<CloseButton handleClick={mockHandleClose} />);
    container = rendered.container;
  });

  it("matches the snapshot", () => {
    expect(container).toMatchSnapshot();
  });

  it("runs handle close when you click close", () => {
    const button = screen.getByTitle("close");
    fireEvent.click(button);
    expect(mockHandleClose).toHaveBeenCalled();
  });
});
