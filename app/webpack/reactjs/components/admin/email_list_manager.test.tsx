import { describe, expect, it } from "@jest/globals";
import { BasePageObject } from "@reactjs/test/base_page_object";
import * as types from "@reactjs/types";
import { api } from "@services/api";
import { emailFactory } from "@test/factories";
import { act, render, waitFor } from "@testing-library/react";
import React from "react";
import { mocked } from "ts-jest/utils";

import { EmailListManager, EmailListManagerProps } from "./email_list_manager";

jest.mock("@services/api");
const mockApi = mocked(api, true);

class EmailListManagerPageObject extends BasePageObject {
  props: EmailListManagerProps;
  emails: types.EmailAttributes[];

  constructor({ debug, raiseOnFind } = {}) {
    super({ debug, raiseOnFind });
    jest.resetAllMocks();
    this.props = {
      title: "This List",
      info: "Here's why we have this list",
      listId: 4,
    };
    this.emails = emailFactory.buildList(4);
  }

  render() {
    return render(<EmailListManager {...this.props} />);
  }

  setupApiMocks({
    index = true,
    remove = true,
  }: { index?: boolean; remove?: boolean } = {}) {
    if (index) {
      const response = { emails: this.emails.map((email) => ({ email })) };
      mockApi.emailLists.emails.index.mockResolvedValue(response);
    } else {
      mockApi.emailLists.emails.index.mockRejectedValue({
        errors: { email: ["bad email"] },
      });
    }

    if (remove) {
      mockApi.emailLists.emails.remove.mockResolvedValue({});
    } else {
      mockApi.emailLists.emails.remove.mockRejectedValue({});
    }
  }

  get title() {
    return this.find(this.props.title);
  }
}

describe("EmailListManager", () => {
  let po: EmailListManagerPageObject;

  beforeEach(() => {
    po = new EmailListManagerPageObject();
  });

  describe("with successful api calls", () => {
    beforeEach(() => {
      po.setupApiMocks();
    });
    it("renders a list of emails and names", async () => {
      act(() => {
        po.render();
      });
      await waitFor(() => {
        po.emails.forEach(({ email, name }) => {
          expect(po.find(`<${email}>`, { exact: false })).toBeInTheDocument();
          expect(po.find(name, { exact: false })).toBeInTheDocument();
        });
      });
    });

    it("renders a list the list title", async () => {
      act(() => {
        po.render();
      });
      await waitFor(() => {
        expect(po.title).toBeInTheDocument();
      });
    });
  });

  describe("when get emails fails", () => {
    beforeEach(() => {
      po.setupApiMocks({ index: false });
    });
    it("renders a list of emails and names", async () => {
      act(() => {
        po.render();
      });
      await waitFor(() => {
        expect(po.find("Ack. Something went awry.")).toBeInTheDocument();
      });
    });

    it("renders a list the list title", async () => {
      act(() => {
        po.render();
      });
      await waitFor(() => {
        expect(po.title).toBeInTheDocument();
      });
    });
  });
});
