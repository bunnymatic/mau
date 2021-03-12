import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import React from "react";

import { ConfirmModal } from "./confirm_modal";

describe("ConfirmModal", () => {
  it("works with button text", () => {
    const { container } = render(
      <ConfirmModal id="my-modal" buttonText="click here to confirm">
        this is the confirm message
      </ConfirmModal>
    );
    expect(container).toMatchSnapshot();
  });

  it("works with button text and style", () => {
    const { container } = render(
      <ConfirmModal
        id="my-modal"
        buttonText="click here to confirm"
        buttonStyle="primary"
      />
    );
    expect(container).toMatchSnapshot();
  });

  it("when i click the button the modal opens", async () => {
    act(() => {
      render(
        <ConfirmModal
          id="my-modal"
          buttonText="click here to confirm"
          buttonStyle="primary"
        >
          this is the confirm message
        </ConfirmModal>
      );
    });
    await waitFor(() => {
      expect(
        screen.queryByRole("button", { name: "click here to confirm" })
      ).toBeInTheDocument();
    });
    act(() => {
      const confirm = screen.queryByRole("button", {
        name: "click here to confirm",
      });
      fireEvent.click(confirm);
    });
    await waitFor(() => {
      expect(
        screen.queryByText("this is the confirm message")
      ).toBeInTheDocument();
    });
    act(() => {
      const yes = screen.queryByText("Yes")?.closest("button");
      fireEvent.click(yes);
    });
  });

  it("when i click yes and the button the modal opens", () => {
    const mockConfirm = jest.fn();
    render(
      <ConfirmModal
        id="my-modal"
        buttonText="click here to confirm"
        buttonStyle="primary"
        handleConfirm={mockConfirm}
      >
        this is the confirm message
      </ConfirmModal>
    );
    expect(
      screen.queryByRole("button", { name: "click here to confirm" })
    ).toBeInTheDocument();
    let confirm;
    confirm = screen.queryByRole("button", { name: "click here to confirm" });
    fireEvent.click(confirm);
    expect(
      screen.queryByText("this is the confirm message")
    ).toBeInTheDocument();
    const yes = screen.queryByText("Yes")?.closest("button");
    fireEvent.click(yes);
    expect(mockConfirm).toHaveBeenCalledWith(true);

    confirm = screen.queryByRole("button", { name: "click here to confirm" });
    fireEvent.click(confirm);
    expect(
      screen.queryByText("this is the confirm message")
    ).toBeInTheDocument();
    const no = screen.queryByText("No")?.closest("button");
    fireEvent.click(no);
    expect(mockConfirm).toHaveBeenCalledWith(false);
  });
});
