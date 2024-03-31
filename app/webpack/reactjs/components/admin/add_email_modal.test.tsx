import { describe, expect, it } from "@jest/globals";
import { all } from "@js/app/helpers";
import { BasePageObject } from "@reactjs/test/base_page_object";
import { api } from "@services/api";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import { mocked } from "jest-mock";
import React from "react";

import { AddEmailModal, AddEmailModalProps } from "./add_email_modal";

jest.mock("@services/api");
const mockApi = mocked(api, true);

class AddEmailModalPageObject extends BasePageObject {
  defaultProps: AddEmailModalProps;

  constructor({ debug, raiseOnFind } = {}) {
    super({ debug, raiseOnFind });
    jest.resetAllMocks();
    this.defaultProps = {
      listId: 4,
      onAdd: jest.fn(),
    };
  }
  render(props) {
    return render(<AddEmailModal {...props} {...this.defaultProps} />);
  }

  setupApiMocks({ save = true }: { save?: boolean } = {}) {
    if (save) {
      mockApi.emailLists.emails.save.mockResolvedValue({
        email: "newemail@example.com",
        name: "new name",
      });
    } else {
      mockApi.emailLists.emails.save.mockRejectedValue({
        errors: { email: ["bad email"] },
      });
    }
  }

  openModal() {
    fireEvent.click(this.openModalButton);
  }

  fillInForm({ email, name }) {
    const emailField = this.inputField("Email");
    this.fillInInput(emailField, email);
    const nameField = this.inputField("Name");
    this.fillInInput(nameField, name);
  }

  showsModalContents() {
    return all(this.modalContents.map((element) => Boolean(element)));
  }

  get modalContents() {
    return [
      screen.queryByText("Email to Add"),
      screen.queryByLabelText("Email"),
      screen.queryByLabelText("Name"),
    ];
  }

  get openModalButton() {
    return screen.queryByRole("button", { name: "add an email to this list" });
  }

  get submitButton() {
    return screen.queryByText("Add");
  }

  inputField(label: string) {
    return screen.queryByLabelText(label).closest("input");
  }

  get flashError() {
    // note: mock ajax failure is problematic because we want `responseJSON` which is derived or something (ugh)
    // so we're just testing that the catch executed
    return screen.queryByText("Ack. Something is not right!");
  }
}

describe("AddEmailModal", () => {
  let po: AddEmailModalPageObject;

  beforeEach(() => {
    po = new AddEmailModalPageObject({ raiseOnFind: true });
  });

  describe("with the modal open", () => {
    it("shows the form", async () => {
      po.render();
      act(() => {
        po.openModal();
      });

      await waitFor(() => {
        expect(po.showsModalContents()).toBe(true);
      });
    });
  });
  describe("when i fill in the form and it submits successfully", () => {
    beforeEach(() => {
      po.setupApiMocks();
    });
    it("saves the record and closes the modal", async () => {
      po.render();
      act(() => {
        po.openModal();
      });

      await waitFor(() => {
        expect(po.showsModalContents()).toBe(true);
      });

      act(() => {
        po.fillInForm({ email: "jon@example.com", name: "jon" });
      });

      await waitFor(() => {
        expect(po.submitButton).toBeInTheDocument();
        expect(po.submitButton).not.toBeDisabled();
      });

      act(() => {
        po.clickButton(po.submitButton);
      });

      await waitFor(() => {
        expect(mockApi.emailLists.emails.save).toHaveBeenCalledWith(
          po.defaultProps.listId,
          { email: { email: "jon@example.com", name: "jon" } }
        );
      });

      await waitFor(() => {
        expect(po.showsModalContents()).toBe(false);
      });
    });
  });
  describe("on a failed submit", () => {
    beforeEach(() => {
      po.setupApiMocks({ save: false });
    });

    it("shows the errors", async () => {
      po.render();
      act(() => {
        po.openModal();
      });

      await waitFor(() => {
        expect(po.showsModalContents()).toBe(true);
      });

      act(() => {
        po.fillInForm({ email: "jon@example.com", name: "jon" });
      });

      await waitFor(() => {
        expect(po.submitButton).toBeInTheDocument();
        expect(po.submitButton).not.toBeDisabled();
      });

      act(() => {
        po.clickButton(po.submitButton);
      });

      await waitFor(() => {
        expect(mockApi.emailLists.emails.save).toHaveBeenCalledWith(
          po.defaultProps.listId,
          { email: { email: "jon@example.com", name: "jon" } }
        );
        expect(po.flashError).toBeInTheDocument();
      });
    });
  });
});
