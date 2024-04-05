import { describe, expect, it, jest } from "@jest/globals";

import * as helpers from "./typed_helpers";

describe("helpers", () => {
  describe("isNil", () => {
    it("returns true if the value is null or undefined", () => {
      expect(helpers.isNil<null>(null)).toEqual(true);
      expect(helpers.isNil<string | null | undefined>(undefined)).toEqual(true);
    });
    it("returns false if the value defined", () => {
      expect(helpers.isNil<number>(0)).toEqual(false);
      expect(helpers.isNil<unknown>(1 / 0)).toEqual(false);
      expect(helpers.isNil(NaN)).toEqual(false);
      expect(helpers.isNil("")).toEqual(false);
    });
  });

  describe("some", () => {
    it("returns true if any of the entries test true with javascript truthy", () => {
      expect(helpers.some([null, undefined, 0, ""])).toBeFalsy();
      expect(helpers.some([false, false])).toBeFalsy();
      expect(helpers.some([null, undefined, []])).toBeTruthy();
      expect(helpers.some([1])).toBeTruthy();
    });

    it("handles an empty array", () => {
      expect(helpers.some([])).toBeFalsy();
    });

    it("honors a comparator function", () => {
      const comparator = (v) => v === "this";
      expect(helpers.some([null, undefined, 0, ""], comparator)).toBeFalsy();
      expect(helpers.some([null, undefined, []], comparator)).toBeFalsy();
      expect(helpers.some([null, "this"], comparator)).toBeTruthy();
    });

    it("returns false if the input is null/undefined", () => {
      expect(helpers.some(null)).toBeFalsy();
      expect(helpers.some(undefined)).toBeFalsy();
    });
  });

});
