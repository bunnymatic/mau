import { renderInForm } from "@reactjs/test/renderers";
import React from "react";

import { MauTextField } from "./mau_text_field";

describe("MauTextField", () => {
  it("matches the snapshot", () => {
    const { container } = renderInForm(
      <MauTextField
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
      <MauTextField
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
