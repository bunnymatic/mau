import { fireEvent, render, screen } from "@testing-library/react";
import React from "react";

import { CloseButton } from "./close_button";

describe("CloseButton", () => {
  let mockHandleClose = jest.fn();
  let container;
  beforeEach(() => {
    const rendered = render(<CloseButton handleClick={mockHandleClose} />);
    container = rendered.container;
    jest.resetAllMocks();
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
