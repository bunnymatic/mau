import { renderInForm } from "@reactjs/test/renderers";
import { render } from "@testing-library/react";
import React from "react";

import { MauCheckboxField } from "./mau_checkbox_field";

describe("MauCheckboxField", () => {
  it("matches the snapshot", () => {
    const container = renderInForm(
      <MauCheckboxField label="The Label" name="the_name" />
    );
    expect(container).toMatchSnapshot();
  });
});
