import { describe, it, expect } from "@jest/globals";
import { render, screen } from "@testing-library/react";
import { MediumLink } from "./medium_link";
import React from 'react'

describe("MediumLink", () => {
  let medium = { name: "my medium", id: 12, slug: "my-tag" };
  let container;

  beforeEach(function () {
    const result = render(<MediumLink medium={medium}/>);
    container = result.container
  });

  it("uses id for the medium path", function () {
    expect(container).toMatchInlineSnapshot(`
      <div>
        <a
          href="/media/my-tag"
        >
          my medium
        </a>
      </div>
    `)
  });
});
