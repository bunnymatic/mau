import { describe, expect, it } from "@jest/globals";

import { backgroundImageStyle } from "./background_image.service";

describe("backgroundImageStyle", () => {
  it("generates a centered covered background style for a url", () => {
    expect(backgroundImageStyle("the-url")).toEqual({
      backgroundImage: 'url("the-url")',
      backgroundSize: "cover",
      backgroundPosition: "center center",
    });
  });

  it("supports extra props", () => {
    expect(
      backgroundImageStyle("the-url", { backgroundOrigin: "20 20" })
    ).toEqual({
      backgroundImage: 'url("the-url")',
      backgroundSize: "cover",
      backgroundPosition: "center center",
      backgroundOrigin: "20 20",
    });
  });

  it("extra props override settings", () => {
    expect(
      backgroundImageStyle("the-url", {
        backgroundPosition: "top left",
        backgroundOrigin: "20 20",
      })
    ).toEqual({
      backgroundImage: 'url("the-url")',
      backgroundSize: "cover",
      backgroundPosition: "top left",
      backgroundOrigin: "20 20",
    });
  });
});
