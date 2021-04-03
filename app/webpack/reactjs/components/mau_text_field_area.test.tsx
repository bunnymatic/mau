import { renderInForm } from "@reactjs/test/renderers";
import React from "react";

import { MauTextAreaField } from "./mau_text_area_field";

describe("MauTextAreaField", () => {
  it("matches the snapshot", () => {
    const { container } = renderInForm(
      <MauTextAreaField
        label="The Label"
        name="the_name"
        placeholder="e.g. like this"
        hint={<span>here is a clue</span>}
      />
    );
    expect(container).toMatchSnapshot();
  });

  it("matches the snapshot if id is provided", () => {
    const { container } = renderInForm(
      <MauTextAreaField
        id="different-than-name"
        label="The Label"
        name="the_name"
        placeholder="e.g. like this"
        hint={<span>here is a clue</span>}
      />
    );
    expect(container).toMatchSnapshot();
  });
});
