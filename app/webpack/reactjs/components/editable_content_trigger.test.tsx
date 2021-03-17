import * as types from "@reactjs/types";
import { render, screen } from "@testing-library/react";
import React from "react";

import { EditableContentTrigger } from "./editable_content_trigger";

describe("EditableContentTrigger", () => {
  const renderComponent = (
    opts: types.CmsDocument = {
      cmsid: undefined,
      page: "myPage",
      section: "mySection",
    }
  ) => {
    return render(<EditableContentTrigger {...opts} />);
  };

  it("renders an edit button", () => {
    const { container } = renderComponent();
    expect(container).toMatchSnapshot();
  });

  it("given a cmsid, it makes an edit path", () => {
    renderComponent({ cmsid: 5 });
    const trigger = screen.queryByText("edit me");
    const link = trigger.closest("a");
    expect(trigger).toBeInTheDocument();
    expect(link.href).toEqual("http://localhost/admin/cms_documents/5/edit");
  });

  it("given no cmsid, it makes an new path", () => {
    renderComponent();
    const trigger = screen.queryByText("edit me");
    const link = trigger.closest("a");
    expect(trigger).toBeInTheDocument();
    expect(link.href).toEqual(
      "http://localhost/admin/cms_documents/new?cms_document[page]=myPage&cms_document[section]=mySection"
    );
  });
});
