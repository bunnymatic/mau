import { act, waitFor } from "@testing-library/react";
import { beforeEach, describe, it, vi } from "vitest";

import { NotifyMauDialogPageObject } from "./notify_mau_dialog.po";

describe("NotifyMauDialog", () => {
  let po: NotifyMauDialogPageObject;

  beforeEach(() => {
    vi.resetAllMocks();
    po = new NotifyMauDialogPageObject();
    po.setupApiMocks(true);
  });

  it("renders a button/link", function () {
    po.renderComponent();
    po.findButton("Here we go");
  });

  it("clicking the button shows the form and submits data on success", async function () {
    po.renderComponent({
      noteType: "inquiry",
      linkText: "Click here to ask a question",
      email: "whatever@somewhere.com",
    });
    const triggerButton = po.findButton("Click here to ask a question");
    po.clickButton(triggerButton);

    expect(po.find("Ask us a question?")).toBeInTheDocument();
    expect(
      po.find("We love to hear from you", { exact: false })
    ).toBeInTheDocument();

    const emailInput = po.findInput("Email");
    expect(emailInput.value).toEqual("whatever@somewhere.com");

    const confirmEmailInput = po.findInput("Confirm Email");
    expect(confirmEmailInput.value).toEqual("whatever@somewhere.com");

    act(() => {
      const noteInput = po.findInput("Your Question");

      po.fillInInput(noteInput, "this is my note to you");
    });

    await waitFor(() => {
      const noteInput = po.findInput("Your Question");

      expect(noteInput.value).toEqual("this is my note to you");
    });

    act(() => {
      const submitButton = po.findButton("Send", { hidden: true });
      po.clickButton(submitButton);
    });
    await waitFor(() => {
      po.find("Thanks for your inquiry", { exact: false });
      expect(po.sendInquiryMock).toHaveBeenCalledWith({
        email: "whatever@somewhere.com",
        emailConfirm: "whatever@somewhere.com",
        inquiry: "this is my note to you",
        noteType: "inquiry",
      });
    });
  });
});
