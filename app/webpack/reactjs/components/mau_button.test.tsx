import { MauButton } from "./mau_button";
import { fireEvent, render, screen } from "@testing-library/react";
import React from 'react';

describe("MauButton", () => {
  let button;

  const renderComponent = ({children, ...props}) => {
    render(<MauButton {...props} >{children}</MauButton>)
  }

  it("renders a button", () => {
    renderComponent({children: "this button"});
    expect(screen.queryByRole("button", {name: "this button"})).toBeInTheDocument()
  })

  it("has the basic classes", () => {
    renderComponent({children: "this button"});
    const button = screen.getByRole("button", {name: "this button"})
    expect(button.className).toContain("pure-button")
  })

  it("renders a primary button with primary: true", () => {
    renderComponent({children: "this button", primary: true});
    const button = screen.getByRole("button", {name: "this button"})
    expect(button.className).toContain("button-primary")
  })

  it("runs onClick when it's pressed", () => {
    const onClick = jest.fn()
    renderComponent({children: "this button", primary: true, onClick});
    const button = screen.getByRole("button", {name: "this button"})
    fireEvent.click(button)
    expect(onClick).toHaveBeenCalled()
  })

});
