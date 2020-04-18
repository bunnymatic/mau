import expect from "expect";

import { isOverflowing } from "./jquery.isOverflowing";

jest.dontMock("jquery");

describe("isOverflowing", function () {
  it("is not overflowing with a small amount of content", function () {
    const element = {
      scrollHeight: 0,
      offsetHeight: 10,
      scrollWidth: 0,
      offsetWidth: 10,
    };
    expect(isOverflowing(element)).toBeFalsy();
  });

  it("is overflowing with lots of content", function () {
    let element = {
      scrollHeight: 20,
      offsetHeight: 10,
      scrollWidth: 0,
      offsetWidth: 10,
    };
    expect(isOverflowing(element)).toBeTruthy();
    element = {
      scrollHeight: 0,
      offsetHeight: 10,
      scrollWidth: 20,
      offsetWidth: 10,
    };
    expect(isOverflowing(element)).toBeTruthy();
  });
});
