import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { OpenStudiosRegistration } from "./open_studios_registration";
import React from 'react';
import expect from 'expect';

import { api } from "@js/services/api";

jest.mock("@js/services/api");

describe("OpenStudiosRegistration", () => {

  const defaultOsEvent = {
    dateRange: "The dates of the event",
  };
  const defaultProps = {
    participating: false,
    autoRegister: false,
    openStudiosEvent: defaultOsEvent,
    location: "The Location Is Here",
  }

  const renderComponent = (props = {}) => {
    const mergedProps = { ...defaultProps, ...props };
    render(<OpenStudiosRegistration { ...mergedProps } />)
  }

  beforeEach(() => {
    jest.resetAllMocks();
  })

  it("shows a register button and message if you're not already participating", () => {
    renderComponent({participating: false})
    const button = screen.queryByRole("button", {name: "Yes - Register Me"})
    expect(screen.queryByText("Will you be participating", {exact: false})).toBeInTheDocument()

  })

  it("shows an update button and message if you're already participating", () => {
    renderComponent({participating: true})
    const button = screen.queryByRole("button", {name: "Update my registration status"})
    expect(screen.queryByText("Yay! You are currently registered for Open Studios on The dates of the event", {exact: false})).toBeInTheDocument()

  })

  it("if autoRegister is true, the modal starts open", () => {
    renderComponent({autoRegister: true})
    expect(screen.queryByText("You are registering to participate as an Open Studios artist for The dates of the event.", {exact: false})).toBeInTheDocument()
  })

  it("clicking the button opens a modal", () =>{
    renderComponent({participating: true})

    const button = screen.queryByRole("button", {name: "Update my registration status"})
    fireEvent.click(button)
    expect(screen.queryByText("You are registering to participate as an Open Studios artist for The dates of the event.",{exact: false})).toBeInTheDocument()
  })

  describe("when I register", () => {
    beforeEach(() => {
      api.users.whoami.mockResolvedValue({currentUser: { slug: 'the-artist'}});
      api.users.registerForOs.mockResolvedValue({});
    });
    it ("allows me to register", async () => {
      let yesButton
      let modalButton
      renderComponent()
      act( () => {
        modalButton = screen.queryByRole("button", {name: "Yes - Register Me"})
        fireEvent.click(modalButton)
      })
      await waitFor(() => {
        yesButton = screen.queryByText("Yes")
        expect(yesButton).toBeInTheDocument()
      })
      act( () => {
        fireEvent.click(yesButton)
      })
      await waitFor(() => {
        expect(api.users.registerForOs).toHaveBeenCalledWith('the-artist',true);
      });
    });
    it ("allows me decline to register", async () => {
      let noButton
      let modalButton
      renderComponent()
      act( () => {
        modalButton = screen.queryByRole("button", {name: "Yes - Register Me"})
        fireEvent.click(modalButton)
      })
      await waitFor(() => {
        noButton = screen.queryByText("No")
        expect(noButton).toBeInTheDocument()
      })
      act( () => {
        fireEvent.click(noButton)
      })
      await waitFor(() => {
        expect(api.users.registerForOs).toHaveBeenCalledWith('the-artist',false);
      });
    });

  })

});
