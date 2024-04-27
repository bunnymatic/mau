import { expect } from "vitest";

import { IsOverflowing } from "./is_overflowing";

describe("isOverflowing", function () {
  it("is not overflowing with a small amount of content", function () {
    const element = {
      scrollHeight: 0,
      offsetHeight: 10,
      scrollWidth: 0,
      offsetWidth: 10,
    } as HTMLElement;
    expect(new IsOverflowing(element).test()).toBe(false);
  });

  it("is overflowing with lots of content", function () {
    let element = {
      scrollHeight: 20,
      offsetHeight: 10,
      scrollWidth: 0,
      offsetWidth: 10,
    } as HTMLElement;
    expect(new IsOverflowing(element).test()).toBe(true);
    element = {
      scrollHeight: 0,
      offsetHeight: 10,
      scrollWidth: 20,
      offsetWidth: 10,
    } as HTMLElement;
    expect(new IsOverflowing(element).test()).toBe(true);
  });
});
