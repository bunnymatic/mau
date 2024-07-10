import { BasePageObject } from "@reactjs/test/base_page_object";
import * as notificationService from "@services/notification.service";
import { render } from "@testing-library/react";
import React from "react";
import { vi } from "vitest";

import { NoteTypes, NotifyMauDialog } from "./notify_mau_dialog";

const mockSendInquiry = vi.spyOn(notificationService, "sendInquiry");

export class NotifyMauDialogPageObject extends BasePageObject {
  constructor() {
    super();
  }

  renderComponent(props?: Record<string, any>) {
    const defaultProps: { noteType: NoteTypes; linkText: string } = {
      noteType: "inquiry",
      linkText: "Here we go",
    };
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
