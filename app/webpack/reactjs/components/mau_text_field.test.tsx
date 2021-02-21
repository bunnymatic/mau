import { MauTextField } from "./mau_text_field";
import { renderInForm } from "@reactjs/test/renderers";
import React from 'react'

describe("MauTextField", () => {
  it("matches the snapshot", () => {
    const {container} = renderInForm(<MauTextField label="The Label" name="the_name" value="the value"  placeholder="e.g. like this" hint={<span>here is a clue</span>} />)
    expect(container).toMatchSnapshot()
  })
});
