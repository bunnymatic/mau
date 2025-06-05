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


describe("ellipsizeParagragh", () => {
  it("ellipsizes paragraphs by taking off the last line that's too big and replacing it with a ...", () => {
    expect(helpers.ellipsizeParagraph("supercal ifra galistic",{max: 5})).toEqual(
      "supercal …"
    );
    expect(helpers.ellipsizeParagraph("sup cal ifra galistic", {max: 5})).toEqual("sup cal …");
  });

  it("uses the input ellipsis character(s)", () => {
    expect(helpers.ellipsizeParagraph("super duper", {max: 5, ellipsis: "custom_ellipsis"})).toEqual(
      "super custom_ellipsis"
    );
  });

  it("does not ellipsize if the string is less than max", () => {
    expect(helpers.ellipsizeParagraph("super duper", {max: 500, ellipsis: "custom_ellipsis"})).toEqual(
      "super duper"
    );
  });

  it("does not ellipsize if the string is ellipsized is longer than the original", () => {
    expect(helpers.ellipsizeParagraph("super duper", {max: 11, ellipsis: 'dots'})).toEqual(
      "super duper"
    );
  });

  it("honors split chars", () => {
    expect(helpers.ellipsizeParagraph("super|duper", {max: 4,  ellipsis: 'dots'})).toEqual(
      "super|duper"
    );
    expect(helpers.ellipsizeParagraph("super|duper",{max: 4,  ellipsis: 'dots', splitChars: [' ', '|']})).toEqual(
      "super|dots"
    );
  });
});

});

