import { isEmpty, noop } from "@js/app/helpers";
import {
  Dispatch,
  SetStateAction,
  useCallback,
  useMemo,
  useState,
} from "react";

interface CarouselStateReturn<T> {
  current: T;
  next: () => T;
  previous: () => T;
  setCurrent: Dispatch<SetStateAction<T>>;
}

export const useCarouselState = <T>(
  items: T[],
  initial?: T
): CarouselStateReturn<T> => {
  const [current, setCurrent] = useState<T>(
    initial ?? (items && items.length ? items[0] : undefined)
  );
  const currentIndex = useMemo(
    () => (items ?? []).findIndex((val) => val === current),
    [current, items]
  );

  const next = useCallback(() => {
    if (isEmpty(items)) {
      return;
    }
    const index: number = (currentIndex + 1) % items.length;
    const newCurrent = items[index];
    setCurrent(newCurrent);
    return newCurrent;
  }, [items, currentIndex]);

  const previous = useCallback(() => {
    if (isEmpty(items)) {
      return;
    }
    let index = currentIndex;
    if (currentIndex <= 0) {
      index = items.length;
    }
    index = index - 1;
    const newCurrent = items[index];
    setCurrent(newCurrent);
    return newCurrent;
  }, [items, currentIndex]);

  if (isEmpty(items)) {
    return {
      current: initial,
      next: noop,
      previous: noop,
      setCurrent: noop,
    };
  }
  return {
    current,
    next,
    previous,
    setCurrent,
  };
};
