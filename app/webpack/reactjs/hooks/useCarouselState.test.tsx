import { describe, expect, it } from "@jest/globals";
import { act, renderHook } from "@testing-library/react-hooks";

import { useCarouselState } from "./useCarouselState";

describe("useCarouselState", () => {
  describe("with an array of strings", () => {
    let result;
    const items = ["a", "b", "c"];

    beforeEach(() => {
      const renderedHook = renderHook(() => useCarouselState(items));
      result = renderedHook.result;
    });
    it("should set current as first", () => {
      expect(result.current.current).toEqual("a");
    });
    it("next should increment current and should roll around", () => {
      expect(result.current.current).toEqual("a");
      act(() => {
        result.current.next();
      });
      expect(result.current.current).toEqual("b");
      act(() => {
        result.current.next();
      });
      expect(result.current.current).toEqual("c");
      act(() => {
        result.current.next();
      });
      expect(result.current.current).toEqual("a");
    });
    it("previous should decrement current and roll around", () => {
      expect(result.current.current).toEqual("a");
      act(() => {
        result.current.previous();
      });
      expect(result.current.current).toEqual("c");
      act(() => {
        result.current.previous();
      });
      expect(result.current.current).toEqual("b");
    });
  });

  describe("with an array of strings and in initial starting point", () => {
    let result;
    const items = ["a", "b", "c"];
    const initial = items[1];

    beforeEach(() => {
      const renderedHook = renderHook(() => useCarouselState(items, initial));
      result = renderedHook.result;
    });
    it("should set current as specified by the initial", () => {
      expect(result.current.current).toEqual("b");
    });
    it("next should increment current and should roll around", () => {
      act(() => {
        result.current.next();
      });
      expect(result.current.current).toEqual("c");
      act(() => {
        result.current.next();
      });
      expect(result.current.current).toEqual("a");
    });
  });

  describe("with an array of objects", () => {
    let result;
    const items = [
      { id: 1, name: "a" },
      { id: 4, name: "b" },
      { id: 12, name: "c" },
    ];
    const initial = items[1];

    beforeEach(() => {
      const renderedHook = renderHook(() => useCarouselState(items, initial));
      result = renderedHook.result;
    });
    it("should set current as specified by the initial", () => {
      expect(result.current.current.id).toEqual(4);
    });
    it("prev should decrement current and should roll around", () => {
      act(() => {
        result.current.previous();
      });
      expect(result.current.current.id).toEqual(1);
      act(() => {
        result.current.previous();
      });
      expect(result.current.current.id).toEqual(12);
    });
  });
});
