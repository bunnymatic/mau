import { api } from "@services/api";
import { jsonApiArtPieceFactory as artPieceFactory } from "@test/factories";
import { fillIn, findButton, findField } from "@test/support/dom_finders";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import React from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { ContactArtistForm } from "./contact_artist_form";

vi.mock("@services/api");

const mockApiContact = api.artPieces.contact;

describe("ContactArtistForm", () => {
  const mockHandleClose = vi.fn();
  const artPiece = artPieceFactory.build();

  const renderComponent = () => {
    render(
      <ContactArtistForm artPiece={artPiece} handleClose={mockHandleClose} />
    );
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("shows the form", async () => {
    act(() => {
      renderComponent();
    });
    await waitFor(() => {
      expect(findField("Your Name")).toBeInTheDocument();
      expect(findField("Your Email")).toBeInTheDocument();
      expect(findField("Your Phone")).toBeInTheDocument();
      expect(findField("Message")).toBeInTheDocument();
      expect(findButton("Send!")).toBeInTheDocument();
      expect(findButton("Cancel")).toBeInTheDocument();

      expect(findButton("Send!")).toBeDisabled();
    });
  });

  it("clicking cancel runs the close callback", () => {
    renderComponent();
    fireEvent.click(findButton("Cancel"));
    expect(mockHandleClose).toHaveBeenCalled();
  });

  describe("filling out the form", () => {
    const fillInForm = () => {
      fillIn(findField("Your Name"), "Jon");
      fillIn(findField("Your Email"), "Jon@example.com");
      fillIn(findField("Message"), "rockin");
    };

    describe("when the note save is successful", () => {
      beforeEach(() => {
        mockApiContact.mockResolvedValue({});
        renderComponent();
      });

      it("and clicking save calls the validation", async () => {
        act(() => {
          fillIn(findField("Your Name"), "Jon");
        });
        await waitFor(() => {});
        act(() => {
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(
            screen.queryAllByText("Email or Phone is required")
          ).toHaveLength(2);
        });
      });

      it("and clicking save calls the api", async () => {
        act(() => {
          fillInForm();
        });
        await waitFor(() => {});
        act(() => {
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(mockApiContact).toHaveBeenCalledWith(artPiece.id, {
            name: "Jon",
            email: "Jon@example.com",
            message: "rockin",
            phone: "",
          });
        });
      });

      it("and clicking save flashes a success message", async () => {
        act(() => {
          fillInForm();
        });
        await waitFor(() => {});
        act(() => {
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(
            screen.queryByText("We sent a note to the artist!", {
              exact: false,
            })
          ).toBeInTheDocument();
        });
      });

      it("and clicking save calls calls close", async () => {
        act(() => {
          fillInForm();
        });
        await waitFor(() => {});
        act(() => {
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(mockHandleClose).toHaveBeenCalled();
        });
      });
    });

    describe("when the note save fails because of server validation errors", () => {
      beforeEach(() => {
        mockApiContact.mockRejectedValue({
          responseJSON: {
            errors: { email: ["should look like an email address."] },
          },
        });
      });

      it("clicking save flashes an error", async () => {
        renderComponent();
        act(() => {
          fillIn(findField("Your Name"), "Jon");
          fillIn(findField("Email"), "jon@example");
          fillIn(findField("Message"), "whatever");
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(
            screen.queryByText("Whoops. There was a problem.")
          ).toBeInTheDocument();
        });
      });

      it("clicking save puts errors on the fields in error", async () => {
        renderComponent();
        act(() => {
          fillIn(findField("Your Name"), "Jon");
          fillIn(findField("Email"), "jon@example");
          fillIn(findField("Message"), "whatever");
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(
            screen.queryByText("should look like an email address.")
          ).toBeInTheDocument();
        });
      });

      it("does not close the dialog", async () => {
        renderComponent();
        act(() => {
          fillIn(findField("Your Name"), "Jon");
          fillIn(findField("Email"), "jon@example");
          fillIn(findField("Message"), "whatever");
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(mockHandleClose).not.toHaveBeenCalled();
        });
      });
    });

    describe("when the note save fails because of something bad", () => {
      beforeEach(() => {
        vi.spyOn(console, "error");
        mockApiContact.mockRejectedValue({});
      });

      it("clicking save flashes an error", async () => {
        renderComponent();
        act(() => {
          fillIn(findField("Your Name"), "Jon");
          fillIn(findField("Email"), "jon@example");
          fillIn(findField("Message"), "whatever");
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(
            screen.queryByText("Ack. Something is seriously wrong.", {
              exact: false,
            })
          ).toBeInTheDocument();
        });
      });

      it("does not close the dialog", async () => {
        renderComponent();
        act(() => {
          fillIn(findField("Your Name"), "Jon");
          fillIn(findField("Email"), "jon@example");
          fillIn(findField("Message"), "whatever");
          fireEvent.click(findButton("Send!"));
        });
        await waitFor(() => {
          expect(mockHandleClose).not.toHaveBeenCalled();
        });
      });
    });
  });
});
