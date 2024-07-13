import { fireEvent, render, screen } from "@testing-library/react";
import React from "react";
import { describe, expect, it, vi } from "vitest";

import { MauTextButton } from "./mau_text_button";

describe("MauTextButton", () => {
  const mockOnClick = vi.fn();
  const renderComponent = ({ children, ...props }) => {
    render(
      <MauTextButton onClick={mockOnClick} {...props}>
        {children}
      </MauTextButton>
    );
  };

  it("has the basic classes", () => {
    renderComponent({ children: "this button" });
    const button = screen.getByRole("button", { name: "this button" });
    expect(button.className).toContain("mau-text-button");
  });

  it("runs onClick when it's pressed", () => {
    renderComponent({ children: "this button" });
    const button = screen.getByRole("button", { name: "this button" });
    fireEvent.click(button);
    expect(mockOnClick).toHaveBeenCalled();
  });
});
