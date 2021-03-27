import { describe, expect, it, jest } from "@jest/globals";

import * as helpers from "./helpers";

describe("helpers", () => {
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
  describe("each", () => {
    it("handles arrays", () => {
      const cb = jest.fn();
      const arr = ["a", "b", "c"];
      helpers.each(arr, cb);
      expect(cb.mock.calls).toHaveLength(3);
      expect(cb.mock.calls[0]).toEqual(["a", 0, arr]);
      expect(cb.mock.calls[1]).toEqual(["b", 1, arr]);
      expect(cb.mock.calls[2]).toEqual(["c", 2, arr]);
    });

    it("handles objects", () => {
      const cb = jest.fn();
      const dictionary = { a: 5, b: 7, c: 9 };
      helpers.each(dictionary, cb);
      expect(cb.mock.calls).toHaveLength(3);
      expect(cb.mock.calls[0]).toEqual([5, "a", dictionary]);
      expect(cb.mock.calls[1]).toEqual([7, "b", dictionary]);
      expect(cb.mock.calls[2]).toEqual([9, "c", dictionary]);
    });
  });

  describe("map", () => {
    it("handles arrays", () => {
      const cb = (v) => v.toUpperCase();
      const arr = ["a", "b", "c"];
      expect(helpers.map(arr, cb)).toEqual(["A", "B", "C"]);
    });

    it("handles objects", () => {
      const cb = (k, v) => `${k}=>${v}`;
      const dictionary = { a: 5, b: 7, c: 9 };
      expect(helpers.map(dictionary, cb)).toEqual(["5=>a", "7=>b", "9=>c"]);
    });
  });

  describe("uniq", () => {
    it("handles arrays", () => {
      const arr = ["a", "b", "b", "b", "c"];
      expect(["a", "b", "c"]).toEqual(helpers.uniq(arr));
    });
  });

  describe("groupBy", () => {
    it("groups a list of items by the given key", () => {
      const data = [
        { type: "A", name: "Apple" },
        { type: "B", name: "Banana" },
        { type: "A", name: "Arrow" },
      ];
      expect(helpers.groupBy(data, "type")).toEqual({
        A: [
          { type: "A", name: "Apple" },
          { type: "A", name: "Arrow" },
        ],
        B: [{ type: "B", name: "Banana" }],
      });
    });

    it("groups a list of items by an arbitrary function", () => {
      const data = ["Left Thing", "Left Stuff", "Right Thing"];
      const prefix = (v) => v.split(/\s+/)[0];
      expect(helpers.groupBy(data, prefix)).toEqual({
        Left: ["Left Thing", "Left Stuff"],
        Right: ["Right Thing"],
      });
    });
  });

  describe("sortBy", () => {
    it("sorts by the given key", () => {
      const data = [
        { type: "B", name: "Banana" },
        { type: "A", name: "Azz" },
        { type: "A", name: "Aaa" },
      ];
      expect(helpers.sortBy(data, "type")).toEqual([
        { type: "A", name: "Azz" },
        { type: "A", name: "Aaa" },
        { type: "B", name: "Banana" },
      ]);
      expect(helpers.sortBy(data, "name")).toEqual([
        { type: "A", name: "Aaa" },
        { type: "A", name: "Azz" },
        { type: "B", name: "Banana" },
      ]);
    });
    it("does not modify the original", () => {
      const data = [
        { type: "A", name: "Azz" },
        { type: "B", name: "Banana" },
        { type: "A", name: "Aaa" },
      ];
      helpers.sortBy(data, "type");
      expect(data[1].type).toEqual("B");
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

  describe("all", () => {
    it("returns true if all of the entries test true with javascript truthy", () => {
      expect(helpers.all([null, undefined, 0, ""])).toBeFalsy();
      expect(helpers.all([null, undefined, []])).toBeFalsy();
      expect(helpers.all([true, false])).toBeFalsy();
      expect(helpers.all([true, true])).toBeTruthy();
      expect(helpers.all([1])).toBeTruthy();
    });

    it("returns false for an empty array", () => {
      expect(helpers.all([])).toBeFalsy();
    });

    it("honors a comparator function", () => {
      const comparator = (v) => v === "this";
      expect(helpers.all([null, undefined, 0, ""], comparator)).toBeFalsy();
      expect(helpers.all([null, "this", 0, ""], comparator)).toBeFalsy();
      expect(helpers.all(["this", "this"], comparator)).toBeTruthy();
    });

    it("returns false if the input is null/undefined", () => {
      expect(helpers.all(null)).toBeFalsy();
      expect(helpers.all(undefined)).toBeFalsy();
    });
  });

  describe("omit", () => {
    it("returns an object with the desired keys omitted", () => {
      const object = { a: 1, b: "2", c: 3 };
      const keys = ["a", "c"];
      expect(helpers.omit(object, keys)).toEqual({ b: "2" });
    });
    it("preserves unmentioned keys", () => {
      const object = { a: 1, b: "2", c: 3, d: 3 };
      const keys = ["a", "c"];
      expect(helpers.omit(object, keys)).toEqual({ b: "2", d: 3 });
    });
    it("works with just a single key", () => {
      const object = { a: 1, b: "2", c: 3, d: 3 };
      const key = "a";
      expect(helpers.omit(object, key)).toEqual({ c: 3, b: "2", d: 3 });
    });
  });

  describe("intersection", () => {
    it("returns an object with the desired keys omitted", () => {
      const arr1 = [0, 1, 5, 9];
      const arr2 = [5, 19];
      expect(helpers.intersection(arr1, arr2)).toEqual([5]);
    });
  });

  describe("dig", () => {
    const testObject = { a: [{ b: { c: 3 } }] };
    it("digs out existing values", () => {
      expect(helpers.dig(testObject, "a[0].b.c", 1)).toEqual(3);
    });
    it("falls back to the default", () => {
      expect(helpers.dig(testObject, "a[0].b.d", 1)).toEqual(1);
    });
    it("safely navigates an unknown path", () => {
      expect(helpers.dig(testObject, "a.b.c.d", 1)).toEqual(1);
    });
    it("works without a default", () => {
      expect(helpers.dig(testObject, "a.b")).toBeUndefined();
    });
  });

  describe("isEmpty", () => {
    it.each([null, "", {}, []])("returns true for '%s'", (emptyThing) => {
      expect(helpers.isEmpty(emptyThing)).toBeTruthy();
    });
    it.each(["a", { a: 1 }, [null, 0]])(
      "returns false for '%s'",
      (fullThing) => {
        expect(helpers.isEmpty(fullThing)).toBeFalsy();
      }
    );
  });

  describe("eachByIndex", () => {
    it("returns an array keyed by 'id' by default", () => {
      const arr = [{ id: 1 }, { id: 4 }, { id: 20 }];
      const result = helpers.eachByIndex(arr);
      expect(result).toEqual({
        1: { id: 1 },
        4: { id: 4 },
        20: { id: 20 },
      });
    });
    it("returns an array keyed by 'whatever' if you specify the key", () => {
      const arr = [{ whatever: 1 }, { whatever: 4 }, { whatever: 20 }];
      const result = helpers.eachByIndex(arr, "whatever");
      expect(result).toEqual({
        1: { whatever: 1 },
        4: { whatever: 4 },
        20: { whatever: 20 },
      });
    });
  });
});
