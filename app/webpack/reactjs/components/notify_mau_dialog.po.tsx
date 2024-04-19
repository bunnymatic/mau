import { BasePageObject } from "@reactjs/test/base_page_object";
import { sendInquiry } from "@services/notification.service";
import { render } from "@testing-library/react";
import React from "react";
import { vi } from "vitest";

import { NotifyMauDialog } from "./notify_mau_dialog";

vi.mock("@services/notification.service");
const mockSendInquiry = sendInquiry;

export class NotifyMauDialogPageObject extends BasePageObject {
  constructor({ debug, raiseOnFind } = {}) {
    super({ debug, raiseOnFind });
  }

  renderComponent(props) {
    const defaultProps = { noteType: "inquiry", linkText: "Here we go" };
    return render(<NotifyMauDialog {...defaultProps} {...props} />);
  }

  setupApiMocks(success = true) {
    if (success) {
      mockSendInquiry.mockResolvedValue({ it: "worked" });
    } else {
      mockSendInquiry.mockRejectedValue("rats");
    }
  }

  get sendInquiryMock() {
    return mockSendInquiry;
  }
}
