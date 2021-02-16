import { render, screen } from "@testing-library/react";
import { OpenStudiosRegistration } from "./open_studios_registration";
import React from 'react';

describe("OpenStudiosRegistration", () => {

  const renderComponent = (props) => {
    render(<OpenStudiosRegistration {...props} />)
  }

  it("shows a register button and message if you're not already participating", () => {
    renderComponent({participating: false})
    const button = screen.queryByRole("button", {name: "Yes - Register Me"})
    expect(screen.queryByText("Will you be participating", {exact: false})).toBeInTheDocument()

  })

  it("shows a register button and message if you're not already participating", () => {
    renderComponent({participating: true})
    const button = screen.queryByRole("button", {name: "Update my registration status"})
    expect(screen.queryByText("Yay! You are current registered for Open Studios on", {exact: false})).toBeInTheDocument()

  })

});
