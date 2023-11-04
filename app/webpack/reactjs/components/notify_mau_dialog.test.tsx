import { describe, expect, it } from "@jest/globals";
import { render } from "@testing-library/react";
import React from "react";

import { NotifyMauDialog } from "./notify_mau_dialog";

describe("NotifyMauDialog", () => {
  const r = (props) => render(<NotifyMauDialog {...props} />)

  it("uses handles the feedback", function () {
    const container = r({}).container;

  });
});
