import { fireEvent, render, screen } from "@testing-library/react";
import React from "react";
import { describe, expect, it, vi } from "vitest";

import { MauButton } from "./mau_button";

describe("MauButton", () => {
  const renderComponent = ({ children, ...props }) => {
    render(<MauButton {...props}>{children}</MauButton>);
  };

  it("renders a button", () => {
    renderComponent({ children: "this button" });
    expect(
      screen.queryByRole("button", { name: "this button" })
    ).toBeInTheDocument();
  });

  it("has the basic classes", () => {
    renderComponent({ children: "this button" });
    const button = screen.getByRole("button", { name: "this button" });
    expect(button.className).toContain("pure-button");
  });

  it("renders a primary button with primary: true", () => {
    renderComponent({ children: "this button", primary: true });
    const button = screen.getByRole("button", { name: "this button" });
    expect(button.className).toContain("button-primary");
  });

  it("runs onClick when it's pressed", () => {
    const onClick = vi.fn();
    renderComponent({ children: "this button", primary: true, onClick });
    const button = screen.getByRole("button", { name: "this button" });
    fireEvent.click(button);
    expect(onClick).toHaveBeenCalled();
  });
});
