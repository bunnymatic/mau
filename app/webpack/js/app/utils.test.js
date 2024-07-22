import { describe, expect, it } from "vitest";

import { ellipsizeParagraph } from "./utils";

describe("ellipsizeParagragh", () => {
  it("ellipsizes paragraphs by taking off the last line that's too big and replacing it with a ...", () => {
    expect(ellipsizeParagraph("supercal ifra galistic", 5)).toEqual(
      "supercal …"
    );
    expect(ellipsizeParagraph("sup cal ifra galistic", 5)).toEqual("sup cal …");
  });

  it("uses the input ellipsis character(s)", () => {
    expect(ellipsizeParagraph("super duper", 5, "custom_ellipsis")).toEqual(
      "super custom_ellipsis"
    );
  });
});
