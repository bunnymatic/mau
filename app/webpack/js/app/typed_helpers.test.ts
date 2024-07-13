import { describe, expect, it } from "vitest";

import * as helpers from "./typed_helpers";

describe("typed helpers", () => {
  describe("isObject", () => {
    it.each([{}, { a: 1 }, { a: { b: { c: "2" } } }])(
      "returns true for the object %s",
      (obj) => {
        expect(helpers.isObject(obj)).toEqual(true);
      }
    );
    it.each([undefined, null, [], ["a", "b"], 1, "1"])(
      "returns false for the non-object %s",
      (obj) => {
        expect(helpers.isObject(obj)).toEqual(false);
      }
    );
  });
  describe("isNil", () => {
    it("returns true if the value is null or undefined", () => {
      expect(helpers.isNil(null)).toEqual(true);
      expect(helpers.isNil()).toEqual(true);
      expect(helpers.isNil(undefined)).toEqual(true);
    });
    it("returns false if the value defined", () => {
      expect(helpers.isNil(0)).toEqual(false);
      expect(helpers.isNil(1 / 0)).toEqual(false);
      expect(helpers.isNil(NaN)).toEqual(false);
      expect(helpers.isNil("")).toEqual(false);
    });
  });
});
